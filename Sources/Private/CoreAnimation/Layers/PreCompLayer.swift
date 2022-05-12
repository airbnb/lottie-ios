// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - PreCompLayer

/// The `CALayer` type responsible for rendering `PreCompLayerModel`s
final class PreCompLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(
    preCompLayer: PreCompLayerModel,
    context: LayerContext)
    throws
  {
    self.preCompLayer = preCompLayer

    if let timeRemappingKeyframes = preCompLayer.timeRemapping {
      timeRemappingInterpolator = .timeRemapping(keyframes: timeRemappingKeyframes, animation: context.animation)
    } else {
      timeRemappingInterpolator = nil
    }

    super.init(layerModel: preCompLayer)

    try setupLayerHierarchy(
      for: context.animation.assetLibrary?.precompAssets[preCompLayer.referenceID]?.layers ?? [],
      context: context)
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

  override func setupAnimations(context: LayerAnimationContext) throws {
    var context = context
    context = context.addingKeypathComponent(preCompLayer.name)
    try setupLayerAnimations(context: context)

    // Precomp layers can adjust the local time of their child layers (relative to the
    // animation's global time) via `timeRemapping` or a custom `startTime`
    let contextForChildren = context.withTimeRemapping { [preCompLayer, timeRemappingInterpolator] layerLocalFrame in
      if let timeRemappingInterpolator = timeRemappingInterpolator {
        return timeRemappingInterpolator.value(frame: layerLocalFrame) as? AnimationFrameTime ?? layerLocalFrame
      } else {
        return layerLocalFrame + AnimationFrameTime(preCompLayer.startTime)
      }
    }

    try setupChildAnimations(context: contextForChildren)
  }

  // MARK: Private

  private let preCompLayer: PreCompLayerModel
  private let timeRemappingInterpolator: KeyframeInterpolator<AnimationFrameTime>?

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
    keyframes timeRemappingKeyframes: KeyframeGroup<Vector1D>,
    animation: Animation)
    -> KeyframeInterpolator<AnimationFrameTime>
  {
    // `timeRemapping` is a mapping from the animation's global time to the layer's local time.
    // In the Core Animation engine, we need to perform the opposite calculation -- convert
    // the layer's local time into the animation's global time. We can get this by inverting
    // the time remapping, swapping the x axis (global time) and the y axis (local time).
    let localTimeToGlobalTimeMapping = timeRemappingKeyframes.keyframes.map { keyframe in
      Keyframe(
        value: keyframe.time,
        time: keyframe.value.cgFloatValue * CGFloat(animation.framerate),
        isHold: keyframe.isHold,
        inTangent: keyframe.inTangent,
        outTangent: keyframe.outTangent,
        spatialInTangent: keyframe.spatialInTangent,
        spatialOutTangent: keyframe.spatialOutTangent)
    }

    return KeyframeInterpolator(keyframes: .init(localTimeToGlobalTimeMapping))
  }
}
