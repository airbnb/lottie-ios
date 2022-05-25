// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - CoreAnimationLayer

/// The root `CALayer` of the Core Animation rendering engine
final class CoreAnimationLayer: BaseAnimationLayer {

  // MARK: Lifecycle

  /// Initializes a `CALayer` that renders the given animation using `CAAnimation`s.
  ///  - This initializer is throwing, but will only throw when using
  ///    `CompatibilityTracker.Mode.abort`.
  init(
    animation: Animation,
    imageProvider: AnimationImageProvider,
    fontProvider: AnimationFontProvider,
    compatibilityTrackerMode: CompatibilityTracker.Mode)
    throws
  {
    self.animation = animation
    self.imageProvider = imageProvider
    self.fontProvider = fontProvider
    compatibilityTracker = CompatibilityTracker(mode: compatibilityTrackerMode)
    super.init()

    setup()
    try setupChildLayers()
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
    didSetUpAnimation = typedLayer.didSetUpAnimation
    compatibilityTracker = typedLayer.compatibilityTracker
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

  /// A closure that is called after this layer sets up its animation.
  /// If the animation setup was unsuccessful and encountered compatibility issues,
  /// those issues are included in this call.
  var didSetUpAnimation: (([CompatibilityIssue]) -> Void)?

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
    // We intentionally don't call `super.display()`, since this layer
    // doesn't directly render any content.
    //  - This fixes an issue where certain animations would unexpectedly
    //    allocate a very large amount of memory (400mb+).
    //  - Alternatively this layer could subclass `CATransformLayer`,
    //    but this causes Core Animation to emit unnecessary logs.

    if let pendingAnimationConfiguration = pendingAnimationConfiguration {
      self.pendingAnimationConfiguration = nil

      do {
        try setupAnimation(for: pendingAnimationConfiguration.animationConfiguration)
      } catch {
        if case CompatibilityTracker.Error.encounteredCompatibilityIssue(let compatibilityIssue) = error {
          // Even though the animation setup failed, we still update the layer's playback state
          // so it can be read by the parent `AnimationView` when handling this error
          currentPlaybackState = pendingAnimationConfiguration.playbackState

          didSetUpAnimation?([compatibilityIssue])
          return
        }
      }

      currentPlaybackState = pendingAnimationConfiguration.playbackState

      compatibilityTracker.reportCompatibilityIssues { compatibilityIssues in
        didSetUpAnimation?(compatibilityIssues)
      }
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
  private let compatibilityTracker: CompatibilityTracker

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
      fontProvider: fontProvider,
      compatibilityTracker: compatibilityTracker,
      layerName: "root layer")
  }

  private func setup() {
    bounds = animation.bounds
  }

  private func setupChildLayers() throws {
    try setupLayerHierarchy(
      for: animation.layers,
      context: layerContext)
  }

  /// Immediately builds and begins playing `CAAnimation`s for each sublayer
  private func setupAnimation(for configuration: AnimationConfiguration) throws {
    // Remove any existing animations from the layer hierarchy
    removeAnimations()

    currentAnimationConfiguration = configuration

    let layerContext = LayerAnimationContext(
      animation: animation,
      timingConfiguration: configuration.timingConfiguration,
      startFrame: configuration.animationContext.playFrom,
      endFrame: configuration.animationContext.playTo,
      valueProviderStore: valueProviderStore,
      compatibilityTracker: compatibilityTracker,
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
      try (animationLayer as? AnimationLayer)?.setupAnimations(context: layerContext)
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
      let playbackState = playbackState,
      // Don't replace any pending animations that are queued to begin
      // on the next run loop cycle, since an existing pending animation
      // will cause the animation to be rebuilt anyway.
      pendingAnimationConfiguration == nil
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

extension CoreAnimationLayer: RootAnimationLayer {

  var primaryAnimationKey: AnimationKey {
    .specific(#keyPath(animationProgress))
  }

  var isAnimationPlaying: Bool? {
    switch playbackState {
    case .playing:
      return true
    case nil, .paused:
      return false
    }
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
        try? textLayer.configureRenderLayer(with: layerContext)
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
      The Core Animation rendering engine doesn't support querying values for individual frames
      """)
    return nil
  }

  func getOriginalValue(for _: AnimationKeypath, atFrame _: AnimationFrameTime?) -> Any? {
    LottieLogger.shared.assertionFailure("""
      The Core Animation rendering engine doesn't support querying values for individual frames
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
