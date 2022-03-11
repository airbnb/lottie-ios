// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - ExperimentalAnimationLayer

/// The root `CALayer` of the new rendering engine,
/// which leverages the Core Animation render server to
/// animate without executing on the main thread every frame.
final class ExperimentalAnimationLayer: BaseAnimationLayer {

  // MARK: Lifecycle

  init(
    animation: Animation,
    imageProvider: AnimationImageProvider,
    fontProvider: AnimationFontProvider)
  {
    self.animation = animation
    self.imageProvider = imageProvider
    self.fontProvider = fontProvider
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
    imageProvider = typedLayer.imageProvider
    fontProvider = typedLayer.fontProvider
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

  enum PlaybackState: Equatable {
    /// The animation is playing in real-time
    case playing
    /// The animation is statically displaying a specific frame
    case paused(frame: AnimationFrameTime)
  }

  /// The `AnimationImageProvider` that `ImageLayer`s use to retrieve images,
  /// referenced by name in the animation json.
  var imageProvider: AnimationImageProvider {
    didSet { reloadImages() }
  }

  /// The `FontProvider` that `TextLayer`s use to retrieve the `CTFont`
  /// that they should use to render their text content
  var fontProvider: AnimationFontProvider {
    didSet { reloadFonts() }
  }

  /// Queues the animation with the given timing configuration
  /// to begin playing at the next `display()` call.
  ///   - This batches together animations so that even if `playAnimation`
  ///     is called multiple times in the same run loop cycle, the animation
  ///     will only be set up a single time.
  func playAnimation(
    context: AnimationContext,
    timingConfiguration: CAMediaTimingConfiguration,
    playbackState: PlaybackState = .playing)
  {
    pendingAnimationConfiguration = (
      animationConfiguration: .init(animationContext: context, timingConfiguration: timingConfiguration),
      playbackState: playbackState)

    setNeedsDisplay()
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    // If no animation has been set up yet, display the first frame
    // now that the layer hierarchy has been setup and laid out
    if
      pendingAnimationConfiguration == nil,
      currentAnimationConfiguration == nil,
      bounds.size != .zero
    {
      currentFrame = animation.frameTime(forProgress: animationProgress)
    }
  }

  override func display() {
    super.display()

    if let pendingAnimationConfiguration = pendingAnimationConfiguration {
      self.pendingAnimationConfiguration = nil
      setupAnimation(for: pendingAnimationConfiguration.animationConfiguration)
      currentPlaybackState = pendingAnimationConfiguration.playbackState
    }
  }

  // MARK: Private

  private struct AnimationConfiguration: Equatable {
    let animationContext: AnimationContext
    let timingConfiguration: CAMediaTimingConfiguration
  }

  /// The configuration for the most recent animation which has been
  /// queued by calling `playAnimation` but not yet actually set up
  private var pendingAnimationConfiguration: (
    animationConfiguration: AnimationConfiguration,
    playbackState: PlaybackState)?

  /// Configuration for the animation that is currently setup in this layer
  private var currentAnimationConfiguration: AnimationConfiguration?

  /// The current progress of the placeholder `CAAnimation`,
  /// which is also the realtime animation progress of this layer's animation
  @objc private var animationProgress: CGFloat = 0

  private let animation: Animation
  private let valueProviderStore = ValueProviderStore()

  /// The current playback state of the animation that is displayed in this layer
  private var currentPlaybackState: PlaybackState? {
    didSet {
      guard playbackState != oldValue else { return }

      switch playbackState {
      case .playing, nil:
        timeOffset = 0
      case .paused(let frame):
        timeOffset = animation.time(forFrame: frame)
      }
    }
  }

  /// The current or pending playback state of the animation displayed in this layer
  private var playbackState: PlaybackState? {
    pendingAnimationConfiguration?.playbackState ?? currentPlaybackState
  }

  /// Context used when setting up and configuring sublayers
  private var layerContext: LayerContext {
    LayerContext(
      animation: animation,
      imageProvider: imageProvider,
      fontProvider: fontProvider)
  }

  private func setup() {
    bounds = animation.bounds
  }

  private func setupChildLayers() {
    setupLayerHierarchy(
      for: animation.layers,
      context: layerContext)
  }

  /// Immediately builds and begins playing `CAAnimation`s for each sublayer
  private func setupAnimation(for configuration: AnimationConfiguration) {
    // Remove any existing animations from the layer hierarchy
    removeAnimations()

    currentAnimationConfiguration = configuration

    let layerContext = LayerAnimationContext(
      animation: animation,
      timingConfiguration: configuration.timingConfiguration,
      startFrame: configuration.animationContext.playFrom,
      endFrame: configuration.animationContext.playTo,
      valueProviderStore: valueProviderStore,
      currentKeypath: AnimationKeypath(keys: []))

    // Perform a layout pass if necessary so all of the sublayers
    // have the most up-to-date sizing information
    layoutIfNeeded()

    // Set the speed of this layer, which will be inherited
    // by all sublayers and their animations.
    //  - This is required to support scrubbing with a speed of 0
    speed = configuration.timingConfiguration.speed

    // Setup a placeholder animation to let us track the realtime animation progress
    setupPlaceholderAnimation(context: layerContext)

    // Set up the new animations with the current `TimingConfiguration`
    for animationLayer in sublayers ?? [] {
      (animationLayer as? AnimationLayer)?.setupAnimations(context: layerContext)
    }
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

  // Removes the current `CAAnimation`s, and rebuilds new animations
  // using the same configuration as the previous animations.
  private func rebuildCurrentAnimation() {
    guard
      let currentConfiguration = currentAnimationConfiguration,
      let playbackState = playbackState
    else { return }

    removeAnimations()

    switch playbackState {
    case .paused(let frame):
      currentFrame = frame

    case .playing:
      playAnimation(
        context: currentConfiguration.animationContext,
        timingConfiguration: currentConfiguration.timingConfiguration)
    }
  }

}

// MARK: RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var primaryAnimationKey: AnimationKey {
    .specific(#keyPath(animationProgress))
  }

  var currentFrame: AnimationFrameTime {
    get {
      switch playbackState {
      case .playing, nil:
        return animation.frameTime(forProgress: (presentation() ?? self).animationProgress)
      case .paused(let frame):
        return frame
      }
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

      if
        pendingAnimationConfiguration == nil,
        currentAnimationConfiguration == requiredAnimationConfiguration
      {
        currentPlaybackState = .paused(frame: newValue)
      }

      else {
        playAnimation(
          context: requiredAnimationConfiguration.animationContext,
          timingConfiguration: requiredAnimationConfiguration.timingConfiguration,
          playbackState: .paused(frame: newValue))
      }
    }
  }

  var renderScale: CGFloat {
    get { contentsScale }
    set {
      contentsScale = newValue

      for sublayer in allSublayers {
        sublayer.contentsScale = newValue
      }
    }
  }

  var respectAnimationFrameRate: Bool {
    get { false }
    set { LottieLogger.shared.assertionFailure("`respectAnimationFrameRate` is currently unsupported") }
  }

  var _animationLayers: [CALayer] {
    (sublayers ?? []).filter { $0 is AnimationLayer }
  }

  var textProvider: AnimationTextProvider {
    get { DictionaryTextProvider([:]) }
    set { LottieLogger.shared.assertionFailure("`textProvider` is currently unsupported") }
  }

  func reloadImages() {
    // When the image provider changes, we have to update all `ImageLayer`s
    // so they can query the most up-to-date image from the new image provider.
    for sublayer in allSublayers {
      if let imageLayer = sublayer as? ImageLayer {
        imageLayer.setupImage(context: layerContext)
      }
    }
  }

  func reloadFonts() {
    // When the text provider changes, we have to update all `TextLayer`s
    // so they can query the most up-to-date font from the new font provider.
    for sublayer in allSublayers {
      if let textLayer = sublayer as? TextLayer {
        textLayer.configureRenderLayer(with: layerContext)
      }
    }
  }

  func forceDisplayUpdate() {
    // Unimplemented / unused
  }

  func logHierarchyKeypaths() {
    // Unimplemented / unused
  }

  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    valueProviderStore.setValueProvider(valueProvider, keypath: keypath)

    // We need to rebuild the current animation after registering a value provider,
    // since any existing `CAAnimation`s could now be out of date.
    rebuildCurrentAnimation()
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
    currentPlaybackState = nil
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
