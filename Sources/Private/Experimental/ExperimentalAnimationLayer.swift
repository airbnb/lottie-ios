// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - ExperimentalAnimationLayer

/// The root `CALayer` of the experimental rendering engine,
/// which leverages the Core Animation render server to
/// animate without executing on the main thread every frame.
final class ExperimentalAnimationLayer: CALayer {

  // MARK: Lifecycle

  init(animation: Animation) {
    self.animation = animation
    super.init()

    setup()
    setupChildLayers()
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let typedLayer = layer as? Self else {
      fatalError("init(layer:) incorrectly called with \(type(of: layer))")
    }

    animation = typedLayer.animation
    super.init(layer: typedLayer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  /// Timing-related configuration to apply to this layer's child `CAAnimation`s
  ///  - This is effectively a configurable subset of `CAMediaTiming`
  struct CAMediaTimingConfiguration {
    var autoreverses = false
    var repeatCount: Float = 0
    var speed: Float = 1
    var timeOffset: TimeInterval = 0
  }

  /// Sets up `CAAnimation`s for each `AnimationLayer` in the layer hierarchy
  func setupAnimation(
    context: AnimationContext,
    timingConfiguration: CAMediaTimingConfiguration)
  {
    self.timingConfiguration = timingConfiguration
    completionHandlerDelegate = context.closure

    let layerContext = LayerAnimationContext(
      animation: animation,
      timingConfiguration: timingConfiguration,
      startFrame: context.playFrom,
      endFrame: context.playTo)

    // Remove any existing animations from the layer hierarchy
    removeAnimations()

    // Perform a layout pass if necessary so all of the sublayers
    // have the most up-to-date sizing information
    layoutIfNeeded()

    // Set the speed of this layer, which will be inherited
    // by all sublayers and their animations.
    //  - This is required to support scrubbing with a speed of 0
    speed = timingConfiguration.speed

    // Setup a placeholder animation to let us track the realtime animation progress
    setupPlaceholderAnimation(context: layerContext)

    // Set up the new animations with the current `TimingConfiguration`
    for animationLayer in sublayers ?? [] {
      (animationLayer as? AnimationLayer)?.setupAnimations(context: layerContext)
    }
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }

    // If no animation has been set up yet, display the first frame
    // now that the layer hierarchy has been setup and laid out
    if
      timingConfiguration == nil,
      bounds.size != .zero
    {
      currentFrame = animation.frameTime(forProgress: animationProgress)
    }
  }

  // MARK: Private

  /// The timing configuration that is being used for the currently-active animation
  private var timingConfiguration: CAMediaTimingConfiguration?

  /// A strong reference to the `AnimationCompletionDelegate`
  /// that serves as the `CAAnimationDelegate` of our animation
  /// (so `AnimationView` can attach a completion handler).
  private var completionHandlerDelegate: AnimationCompletionDelegate?

  /// The current progress of the placeholder `CAAnimation`,
  /// which is also the realtime animation progress of this layer's animation
  @objc private var animationProgress: CGFloat = 0

  private let animation: Animation

  private func setup() {
    bounds = animation.bounds
  }

  private func setupChildLayers() {
    setupLayerHierarchy(
      for: animation.layers,
      context: LayerContext(
        assetLibrary: animation.assetLibrary,
        imageProvider: imageProvider))
  }

  /// Sets up a placeholder `CABasicAnimation` that tracks the current
  /// progress of this animation (between 0 and 1). This lets us provide
  /// realtime animation progress via `self.currentFrame`.
  private func setupPlaceholderAnimation(context: LayerAnimationContext) {
    let animationProgressTracker = CABasicAnimation(keyPath: #keyPath(animationProgress))
    animationProgressTracker.fromValue = 0
    animationProgressTracker.toValue = 1

    let timedProgressAnimation = animationProgressTracker.timed(with: context)
    timedProgressAnimation.delegate = completionHandlerDelegate
    add(timedProgressAnimation, forKey: #keyPath(animationProgress))
  }

}

// MARK: - CALayer + setupLayerHierarchy

extension CALayer {
  /// Sets up an `AnimationLayer` / `CALayer` hierarchy in this layer,
  /// using the given list of layers.
  func setupLayerHierarchy(
    for layers: [LayerModel],
    context: LayerContext)
  {
    // An `Animation`'s `LayerModel`s are listed from front to back,
    // but `CALayer.sublayers` are listed from back to front.
    // We reverse the layer ordering to match what Core Animation expects.
    let layersInZAxisOrder = layers.reversed()

    // Each layer has an index value, which must be unique
    // Layers can optionally specify their parent layer, by index.
    // Since the layers can be listed in any order (e.g. children can
    // come either before or after their children) we have to build
    // all of the layers and _then_ setup the parent/child hierarchy.
    var layersByIndex = [Int: BaseCompositionLayer]()

    // First, we build the `AnimationLayer` / `CALayer` for each `LayerModel
    for layerModel in layersInZAxisOrder {
      guard let layer = layerModel.makeAnimationLayer(context: context) else {
        continue
      }

      if layersByIndex.keys.contains(layerModel.index) {
        LottieLogger.shared.assertionFailure("""
        Multiple layers have the same index \"\(layerModel.index)\".
        This is unsupported.
        """)
      }

      layersByIndex[layerModel.index] = layer
    }

    // Then we add each `AnimationLayer` to the layer hierarchy
    for layerModel in layersInZAxisOrder {
      guard let layer = layersByIndex[layerModel.index] else {
        continue
      }

      // If the layer specified a parent index, we look up the parent
      // and add it as a sublayer of the parent layer
      if
        let parentIndex = layerModel.parent,
        let parentLayer = layersByIndex[parentIndex]
      {
        // Add this child layer to the parent's `transformLayer`
        // so it inherits the parent `LayerModel`'s transform
        parentLayer.transformLayer.addSublayer(layer)
      }

      // Otherwise we add it as a top-level sublayer of this container
      else {
        addSublayer(layer)
      }
    }
  }
}

// MARK: - ExperimentalAnimationLayer + RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var primaryAnimationKey: AnimationKey {
    .specific(#keyPath(animationProgress))
  }

  var currentFrame: AnimationFrameTime {
    get {
      animation.frameTime(forProgress: (presentation() ?? self).animationProgress)
    }
    set {
      // Currently, setting `currentFrame` causes the existing layer hierarchy
      // to be discarded and then completely rebuilt.
      // This isn't a problem when setting the animation up just once,
      // but can max out the CPU (causing frame drops / lag) for very-large animations
      // when interactively controlling the current frame with a user gesture.
      // TODO: This should be adjusted to use the existing layer hierarchy
      //       and control something like `layer.timeOffset`.
      setupAnimation(
        context: .init(
          playFrom: animation.startFrame,
          playTo: animation.endFrame,
          closure: nil),
        timingConfiguration: .init(
          speed: 0,
          timeOffset: animation.time(forFrame: newValue)))
    }
  }

  var renderScale: CGFloat {
    get { 0 }
    set { LottieLogger.shared.assertionFailure("`renderScale` is currently unsupported") }
  }

  var respectAnimationFrameRate: Bool {
    get { false }
    set { LottieLogger.shared.assertionFailure("`respectAnimationFrameRate` is currently unsupported") }
  }

  var _animationLayers: [CALayer] {
    (sublayers ?? []).filter { $0 is AnimationLayer }
  }

  var imageProvider: AnimationImageProvider {
    get { BundleImageProvider(bundle: Bundle.main, searchPath: nil) }
    set { LottieLogger.shared.assertionFailure("Setting `imageProvider` is currently unsupported") }
  }

  var textProvider: AnimationTextProvider {
    get { DictionaryTextProvider([:]) }
    set { LottieLogger.shared.assertionFailure("`textProvider` is currently unsupported") }
  }

  var fontProvider: AnimationFontProvider {
    get { DefaultFontProvider() }
    set { LottieLogger.shared.assertionFailure("`fontProvider` is currently unsupported") }
  }

  func reloadImages() {
    LottieLogger.shared.assertionFailure("`reloadImages` is currently not implemented")
  }

  func forceDisplayUpdate() {
    // Unimplemented / unused
  }

  func logHierarchyKeypaths() {
    // Unimplemented / unused
  }

  func setValueProvider(_: AnyValueProvider, keypath _: AnimationKeypath) {
    LottieLogger.shared.assertionFailure("`AnimationKeypath`s are currently unsupported")
  }

  func getValue(for _: AnimationKeypath, atFrame _: AnimationFrameTime?) -> Any? {
    LottieLogger.shared.assertionFailure("`AnimationKeypath`s are currently unsupported")
  }

  func layer(for _: AnimationKeypath) -> CALayer? {
    LottieLogger.shared.assertionFailure("`AnimationKeypath`s are currently unsupported")
    return nil
  }

  func animatorNodes(for _: AnimationKeypath) -> [AnimatorNode]? {
    LottieLogger.shared.assertionFailure("`AnimatorNode`s are not used in this rendering implementation")
    return nil
  }

  func removeAnimations() {
    removeAllAnimations()
    for sublayer in allSublayers {
      sublayer.removeAllAnimations()
    }
  }

}

// MARK: - CALayer + allSublayers

extension CALayer {
  /// All of the layers in the layer tree that are descendants from this later
  @nonobjc
  var allSublayers: [CALayer] {
    var allSublayers: [CALayer] = []

    for sublayer in sublayers ?? [] {
      allSublayers.append(sublayer)
      allSublayers.append(contentsOf: sublayer.allSublayers)
    }

    return allSublayers
  }
}
