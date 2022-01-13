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
    currentAnimationConfiguration = typedLayer.currentAnimationConfiguration
    super.init(layer: typedLayer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  /// Timing-related configuration to apply to this layer's child `CAAnimation`s
  ///  - This is effectively a configurable subset of `CAMediaTiming`
  struct CAMediaTimingConfiguration: Equatable {
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
    // Remove any existing animations from the layer hierarchy
    removeAnimations()

    currentAnimationConfiguration = AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timingConfiguration)

    let layerContext = LayerAnimationContext(
      animation: animation,
      timingConfiguration: timingConfiguration,
      startFrame: context.playFrom,
      endFrame: context.playTo,
      valueProviderStore: valueProviderStore,
      currentKeypath: AnimationKeypath(keys: []))

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
      currentAnimationConfiguration == nil,
      bounds.size != .zero
    {
      currentFrame = animation.frameTime(forProgress: animationProgress)
    }
  }

  // MARK: Private

  private struct AnimationConfiguration: Equatable {
    let animationContext: AnimationContext
    let timingConfiguration: CAMediaTimingConfiguration
  }

  // Configuration for the animation that is currently playing in this layer
  private var currentAnimationConfiguration: AnimationConfiguration?

  /// The current progress of the placeholder `CAAnimation`,
  /// which is also the realtime animation progress of this layer's animation
  @objc private var animationProgress: CGFloat = 0

  private let animation: Animation
  private let valueProviderStore = ValueProviderStore()

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

    let timedProgressAnimation = animationProgressTracker.timed(with: context, for: self)
    timedProgressAnimation.delegate = currentAnimationConfiguration?.animationContext.closure
    add(timedProgressAnimation, forKey: #keyPath(animationProgress))
  }

}

// MARK: RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var primaryAnimationKey: AnimationKey {
    .specific(#keyPath(animationProgress))
  }

  var currentFrame: AnimationFrameTime {
    get {
      animation.frameTime(forProgress: (presentation() ?? self).animationProgress)
    }
    set {
      // We can display a specific frame of the animation by setting
      // `timeOffset` of this layer. This requires setting up the layer hierarchy
      // with a specific configuration (speed=0, etc) at least once. But if
      // the layer hierarchy is already set up correctly, we can update the
      // `timeOffset` very cheaply.
      let requiredAnimationConfiguration = AnimationConfiguration(
        animationContext: AnimationContext(
          playFrom: animation.startFrame,
          playTo: animation.endFrame,
          closure: nil),
        timingConfiguration: CAMediaTimingConfiguration(speed: 0))

      if currentAnimationConfiguration != requiredAnimationConfiguration {
        setupAnimation(
          context: requiredAnimationConfiguration.animationContext,
          timingConfiguration: requiredAnimationConfiguration.timingConfiguration)
      }

      timeOffset = animation.time(forFrame: newValue)
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

  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    // TODO: We need to rebuild the current animation after registering a value provider,
    // since any existing `CAAnimation`s could now be out of date.
    valueProviderStore.setValueProvider(valueProvider, keypath: keypath)
  }

  func getValue(for _: AnimationKeypath, atFrame _: AnimationFrameTime?) -> Any? {
    LottieLogger.shared.assertionFailure("""
    The new rendering engine doesn't support querying values for individual frames
    """)
    return nil
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
    currentAnimationConfiguration = nil
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
