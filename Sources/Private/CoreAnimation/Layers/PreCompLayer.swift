// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - PreCompLayer

/// The `CALayer` type responsible for rendering `PreCompLayerModel`s
final class PreCompLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(preCompLayer: PreCompLayerModel) {
    self.preCompLayer = preCompLayer
    super.init(layerModel: preCompLayer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let typedLayer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    preCompLayer = typedLayer.preCompLayer
    timeRemappingInterpolator = typedLayer.timeRemappingInterpolator
    super.init(layer: typedLayer)
  }

  // MARK: Internal

  /// Post-init setup for `PreCompLayer`s.
  /// Should always be called after `PreCompLayer.init(preCompLayer:)`.
  ///
  /// This is a workaround for a hard-to-reproduce crash that was
  /// triggered when `PreCompLayer.init` was called reentantly. We didn't
  /// have any consistent repro steps for this crash (it happened 100% of
  /// the time for some testers, and 0% of the time for other testers),
  /// but moving this code out of `PreCompLayer.init` does seem to fix it.
  ///
  /// The stack trace looked like:
  ///  - `_os_unfair_lock_recursive_abort`
  ///  - `-[CALayerAccessibility__UIKit__QuartzCore dealloc]`
  ///  - `PreCompLayer.__allocating_init(preCompLayer:context:)` <- reentrant init call
  ///  - ...
  ///  - `CALayer.setupLayerHierarchy(for:context:)`
  ///  - `PreCompLayer.init(preCompLayer:context:)`
  ///
  func setup(context: LayerContext) throws {
    if let timeRemappingKeyframes = preCompLayer.timeRemapping {
      timeRemappingInterpolator = try .timeRemapping(keyframes: timeRemappingKeyframes, context: context)
    } else {
      timeRemappingInterpolator = nil
    }

    try setupLayerHierarchy(
      for: context.animation.assetLibrary?.precompAssets[preCompLayer.referenceID]?.layers ?? [],
      context: context)
  }

  override func setupAnimations(context: LayerAnimationContext) throws {
    var context = context
    context = context.addingKeypathComponent(preCompLayer.name)
    try setupLayerAnimations(context: context)

    // Precomp layers can adjust the local time of their child layers (relative to the
    // animation's global time) via `timeRemapping` or a custom `startTime` / `timeStretch`
    let contextForChildren = context.withTimeRemapping { [preCompLayer, timeRemappingInterpolator] layerLocalFrame in
      if let timeRemappingInterpolator = timeRemappingInterpolator {
        return timeRemappingInterpolator.value(frame: layerLocalFrame) as? AnimationFrameTime ?? layerLocalFrame
      } else {
        return (layerLocalFrame * AnimationFrameTime(preCompLayer.timeStretch)) + AnimationFrameTime(preCompLayer.startTime)
      }
    }

    try setupChildAnimations(context: contextForChildren)
  }

  // MARK: Private

  private let preCompLayer: PreCompLayerModel
  private var timeRemappingInterpolator: KeyframeInterpolator<AnimationFrameTime>?

}

// MARK: CustomLayoutLayer

extension PreCompLayer: CustomLayoutLayer {
  func layout(superlayerBounds: CGRect) {
    anchorPoint = .zero

    // Pre-comp layers use a size specified in the layer model,
    // and clip the composition to that bounds
    bounds = CGRect(
      x: superlayerBounds.origin.x,
      y: superlayerBounds.origin.y,
      width: CGFloat(preCompLayer.width),
      height: CGFloat(preCompLayer.height))

    masksToBounds = true
  }
}

extension KeyframeInterpolator where ValueType == AnimationFrameTime {
  /// A `KeyframeInterpolator` for the given `timeRemapping` keyframes
  static func timeRemapping(
    keyframes timeRemappingKeyframes: KeyframeGroup<LottieVector1D>,
    context: LayerContext)
    throws -> KeyframeInterpolator<AnimationFrameTime>
  {
    try context.logCompatibilityIssue("""
      The Core Animation rendering engine partially supports time remapping keyframes,
      but this is somewhat experimental and has some known issues. Since it doesn't work
      in all cases, we have to fall back to using the main thread engine when using
      `RenderingEngineOption.automatic`.
      """)

    // `timeRemapping` is a mapping from the animation's global time to the layer's local time.
    // In the Core Animation engine, we need to perform the opposite calculation -- convert
    // the layer's local time into the animation's global time. We can get this by inverting
    // the time remapping, swapping the x axis (global time) and the y axis (local time).
    let localTimeToGlobalTimeMapping = timeRemappingKeyframes.keyframes.map { keyframe in
      Keyframe(
        value: keyframe.time,
        time: keyframe.value.cgFloatValue * CGFloat(context.animation.framerate),
        isHold: keyframe.isHold,
        inTangent: keyframe.inTangent,
        outTangent: keyframe.outTangent,
        spatialInTangent: keyframe.spatialInTangent,
        spatialOutTangent: keyframe.spatialOutTangent)
    }

    return KeyframeInterpolator(keyframes: .init(localTimeToGlobalTimeMapping))
  }
}
