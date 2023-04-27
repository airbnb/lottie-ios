//
//  LottieAnimationView.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/23/19.
//

import Foundation
import QuartzCore

// MARK: - LottieBackgroundBehavior

/// Describes the behavior of an AnimationView when the app is moved to the background.
public enum LottieBackgroundBehavior {
  /// Stop the animation and reset it to the beginning of its current play time. The completion block is called.
  case stop

  /// Pause the animation in its current state. The completion block is called.
  case pause

  /// Pause the animation and restart it when the application moves to the foreground.
  /// The completion block is stored and called when the animation completes.
  ///  - This is the default when using the Main Thread rendering engine.
  case pauseAndRestore

  /// Stops the animation and sets it to the end of its current play time. The completion block is called.
  case forceFinish

  /// The animation continues playing in the background.
  ///  - This is the default when using the Core Animation rendering engine.
  ///    Playing an animation using the Core Animation engine doesn't come with any CPU overhead,
  ///    so using `.continuePlaying` avoids the need to stop and then resume the animation
  ///    (which does come with some CPU overhead).
  ///  - This mode should not be used with the Main Thread rendering engine.
  case continuePlaying

  // MARK: Public

  /// The default background behavior, based on the rendering engine being used to play the animation.
  ///  - Playing an animation using the Main Thread rendering engine comes with CPU overhead,
  ///    so the animation should be paused or stopped when the `LottieAnimationView` is not visible.
  ///  - Playing an animation using the Core Animation rendering engine does not come with any
  ///    CPU overhead, so these animations do not need to be paused in the background.
  public static func `default`(for renderingEngine: RenderingEngine) -> LottieBackgroundBehavior {
    switch renderingEngine {
    case .mainThread:
      return .pauseAndRestore
    case .coreAnimation:
      return .continuePlaying
    }
  }
}

// MARK: - LottieLoopMode

/// Defines animation loop behavior
public enum LottieLoopMode {
  /// Animation is played once then stops.
  case playOnce
  /// Animation will loop from beginning to end until stopped.
  case loop
  /// Animation will play forward, then backwards and loop until stopped.
  case autoReverse
  /// Animation will loop from beginning to end up to defined amount of times.
  case `repeat`(Float)
  /// Animation will play forward, then backwards a defined amount of times.
  case repeatBackwards(Float)
}

// MARK: Equatable

extension LottieLoopMode: Equatable {
  public static func == (lhs: LottieLoopMode, rhs: LottieLoopMode) -> Bool {
    switch (lhs, rhs) {
    case (.repeat(let lhsAmount), .repeat(let rhsAmount)),
         (.repeatBackwards(let lhsAmount), .repeatBackwards(let rhsAmount)):
      return lhsAmount == rhsAmount
    case (.playOnce, .playOnce),
         (.loop, .loop),
         (.autoReverse, .autoReverse):
      return true
    default:
      return false
    }
  }
}

// MARK: - LottieAnimationView

@IBDesignable
open class LottieAnimationView: LottieAnimationViewBase {

  // MARK: Lifecycle

  // MARK: - Public (Initializers)

  /// Initializes an AnimationView with an animation.
  public init(
    animation: LottieAnimation?,
    imageProvider: AnimationImageProvider? = nil,
    textProvider: AnimationTextProvider = DefaultTextProvider(),
    fontProvider: AnimationFontProvider = DefaultFontProvider(),
    configuration: LottieConfiguration = .shared,
    logger: LottieLogger = .shared)
  {
    self.animation = animation
    self.imageProvider = imageProvider ?? BundleImageProvider(bundle: Bundle.main, searchPath: nil)
    self.textProvider = textProvider
    self.fontProvider = fontProvider
    self.configuration = configuration
    self.logger = logger
    super.init(frame: .zero)
    commonInit()
    makeAnimationLayer(usingEngine: configuration.renderingEngine)
    if let animation = animation {
      frame = animation.bounds
    }
  }

  /// Initializes an AnimationView with a .lottie file.
  public init(
    dotLottie: DotLottieFile?,
    animationId: String? = nil,
    textProvider: AnimationTextProvider = DefaultTextProvider(),
    fontProvider: AnimationFontProvider = DefaultFontProvider(),
    configuration: LottieConfiguration = .shared,
    logger: LottieLogger = .shared)
  {
    let dotLottieAnimation = dotLottie?.animation(for: animationId)
    animation = dotLottieAnimation?.animation
    imageProvider = dotLottie?.imageProvider ?? BundleImageProvider(bundle: Bundle.main, searchPath: nil)
    self.textProvider = textProvider
    self.fontProvider = fontProvider
    self.configuration = configuration
    self.logger = logger
    super.init(frame: .zero)
    commonInit()
    loopMode = dotLottieAnimation?.configuration.loopMode ?? .playOnce
    animationSpeed = CGFloat(dotLottieAnimation?.configuration.speed ?? 1)
    makeAnimationLayer(usingEngine: configuration.renderingEngine)
    if let animation = animation {
      frame = animation.bounds
    }
  }

  public init(
    configuration: LottieConfiguration = .shared,
    logger: LottieLogger = .shared)
  {
    animation = nil
    imageProvider = BundleImageProvider(bundle: Bundle.main, searchPath: nil)
    textProvider = DefaultTextProvider()
    fontProvider = DefaultFontProvider()
    self.configuration = configuration
    self.logger = logger
    super.init(frame: .zero)
    commonInit()
  }

  public override init(frame: CGRect) {
    animation = nil
    imageProvider = BundleImageProvider(bundle: Bundle.main, searchPath: nil)
    textProvider = DefaultTextProvider()
    fontProvider = DefaultFontProvider()
    configuration = .shared
    logger = .shared
    super.init(frame: frame)
    commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    imageProvider = BundleImageProvider(bundle: Bundle.main, searchPath: nil)
    textProvider = DefaultTextProvider()
    fontProvider = DefaultFontProvider()
    configuration = .shared
    logger = .shared
    super.init(coder: aDecoder)
    commonInit()
  }

  // MARK: Open

  /// Plays the animation from its current state to the end.
  ///
  /// - Parameter completion: An optional completion closure to be called when the animation completes playing.
  open func play(completion: LottieCompletionBlock? = nil) {
    guard let animation = animation else {
      return
    }

    /// Build a context for the animation.
    let context = AnimationContext(
      playFrom: CGFloat(animation.startFrame),
      playTo: CGFloat(animation.endFrame),
      closure: completion)
    removeCurrentAnimationIfNecessary()
    addNewAnimationForContext(context)
  }

  /// Plays the animation from a progress (0-1) to a progress (0-1).
  ///
  /// - Parameter fromProgress: The start progress of the animation. If `nil` the animation will start at the current progress.
  /// - Parameter toProgress: The end progress of the animation.
  /// - Parameter loopMode: The loop behavior of the animation. If `nil` the view's `loopMode` property will be used.
  /// - Parameter completion: An optional completion closure to be called when the animation stops.
  open func play(
    fromProgress: AnimationProgressTime? = nil,
    toProgress: AnimationProgressTime,
    loopMode: LottieLoopMode? = nil,
    completion: LottieCompletionBlock? = nil)
  {
    guard let animation = animation else {
      return
    }

    removeCurrentAnimationIfNecessary()
    if let loopMode = loopMode {
      /// Set the loop mode, if one was supplied
      self.loopMode = loopMode
    }
    let context = AnimationContext(
      playFrom: animation.frameTime(forProgress: fromProgress ?? currentProgress),
      playTo: animation.frameTime(forProgress: toProgress),
      closure: completion)
    addNewAnimationForContext(context)
  }

  /// Plays the animation from a start frame to an end frame in the animation's framerate.
  ///
  /// - Parameter fromFrame: The start frame of the animation. If `nil` the animation will start at the current frame.
  /// - Parameter toFrame: The end frame of the animation.
  /// - Parameter loopMode: The loop behavior of the animation. If `nil` the view's `loopMode` property will be used.
  /// - Parameter completion: An optional completion closure to be called when the animation stops.
  open func play(
    fromFrame: AnimationFrameTime? = nil,
    toFrame: AnimationFrameTime,
    loopMode: LottieLoopMode? = nil,
    completion: LottieCompletionBlock? = nil)
  {
    removeCurrentAnimationIfNecessary()
    if let loopMode = loopMode {
      /// Set the loop mode, if one was supplied
      self.loopMode = loopMode
    }

    let context = AnimationContext(
      playFrom: fromFrame ?? currentFrame,
      playTo: toFrame,
      closure: completion)
    addNewAnimationForContext(context)
  }

  /// Plays the animation from a named marker to another marker.
  ///
  /// Markers are point in time that are encoded into the Animation data and assigned
  /// a name.
  ///
  /// NOTE: If markers are not found the play command will exit.
  ///
  /// - Parameter fromMarker: The start marker for the animation playback. If `nil` the
  /// animation will start at the current progress.
  /// - Parameter toMarker: The end marker for the animation playback.
  /// - Parameter playEndMarkerFrame: A flag to determine whether or not to play the frame of the end marker. If the
  /// end marker represents the end of the section to play, it should be to true. If the provided end marker
  /// represents the beginning of the next section, it should be false.
  /// - Parameter loopMode: The loop behavior of the animation. If `nil` the view's `loopMode` property will be used.
  /// - Parameter completion: An optional completion closure to be called when the animation stops.
  open func play(
    fromMarker: String? = nil,
    toMarker: String,
    playEndMarkerFrame: Bool = true,
    loopMode: LottieLoopMode? = nil,
    completion: LottieCompletionBlock? = nil)
  {
    guard let animation = animation, let markers = animation.markerMap, let to = markers[toMarker] else {
      return
    }

    removeCurrentAnimationIfNecessary()
    if let loopMode = loopMode {
      /// Set the loop mode, if one was supplied
      self.loopMode = loopMode
    }

    let fromTime: CGFloat
    if let fromName = fromMarker, let from = markers[fromName] {
      fromTime = CGFloat(from.frameTime)
    } else {
      fromTime = currentFrame
    }

    let playTo = playEndMarkerFrame ? CGFloat(to.frameTime) : CGFloat(to.frameTime) - 1
    let context = AnimationContext(
      playFrom: fromTime,
      playTo: playTo,
      closure: completion)
    addNewAnimationForContext(context)
  }

  /// Plays the animation from a named marker to the end of the marker's duration.
  ///
  /// A marker is a point in time with an associated duration that is encoded into the
  /// animation data and assigned a name.
  ///
  /// NOTE: If marker is not found the play command will exit.
  ///
  /// - Parameter marker: The start marker for the animation playback.
  /// - Parameter loopMode: The loop behavior of the animation. If `nil` the view's `loopMode` property will be used.
  /// - Parameter completion: An optional completion closure to be called when the animation stops.
  open func play(
    marker: String,
    loopMode: LottieLoopMode? = nil,
    completion: LottieCompletionBlock? = nil)
  {
    guard let from = animation?.markerMap?[marker] else {
      return
    }

    play(
      fromFrame: from.frameTime,
      toFrame: from.frameTime + from.durationFrameTime,
      loopMode: loopMode,
      completion: completion)
  }

  /// Stops the animation and resets the view to its start frame.
  ///
  /// The completion closure will be called with `false`
  open func stop() {
    removeCurrentAnimation()
    currentFrame = 0
  }

  /// Pauses the animation in its current state.
  ///
  /// The completion closure will be called with `false`
  open func pause() {
    removeCurrentAnimation()
  }

  // MARK: Public

  /// The configuration that this `LottieAnimationView` uses when playing its animation
  public let configuration: LottieConfiguration

  /// Value Providers that have been registered using `setValueProvider(_:keypath:)`
  public private(set) var valueProviders = [AnimationKeypath: AnyValueProvider]()

  /// Describes the behavior of an AnimationView when the app is moved to the background.
  ///
  /// The default for the Main Thread animation engine is `pause`,
  /// which pauses the animation when the application moves to
  /// the background. This prevents the animation from consuming CPU
  /// resources when not on-screen. The completion block is called with
  /// `false` for completed.
  ///
  /// The default for the Core Animation engine is `continuePlaying`,
  /// since the Core Animation engine does not have any CPU overhead.
  public var backgroundBehavior: LottieBackgroundBehavior {
    get {
      let currentBackgroundBehavior = _backgroundBehavior ?? .default(for: currentRenderingEngine ?? .mainThread)

      if
        currentRenderingEngine == .mainThread,
        _backgroundBehavior == .continuePlaying
      {
        logger.assertionFailure("""
          `LottieBackgroundBehavior.continuePlaying` should not be used with the Main Thread
          rendering engine, since this would waste CPU resources on playing an animation
          that is not visible. Consider using a different background mode, or switching to
          the Core Animation rendering engine (which does not have any CPU overhead).
          """)
      }

      return currentBackgroundBehavior
    }
    set {
      _backgroundBehavior = newValue
    }
  }

  /// Sets the animation backing the animation view. Setting this will clear the
  /// view's contents, completion blocks and current state. The new animation will
  /// be loaded up and set to the beginning of its timeline.
  public var animation: LottieAnimation? {
    didSet {
      makeAnimationLayer(usingEngine: configuration.renderingEngine)

      if let animation = animation {
        animationLoaded?(self, animation)
      }
    }
  }

  /// A closure that is called when `self.animation` is loaded. When setting this closure,
  /// it is called immediately if `self.animation` is non-nil.
  ///
  /// When initializing a `LottieAnimationView`, the animation will either be loaded
  /// synchronously (when loading a `LottieAnimation` from a .json file on disk)
  /// or asynchronously (when loading a `DotLottieFile` from disk, or downloading
  /// an animation from a URL). This closure is called in both cases once the
  /// animation is loaded and applied, so can be a useful way to configure this
  /// `LottieAnimationView` regardless of which initializer was used. For example:
  ///
  /// ```
  /// let animationView: LottieAnimationView
  ///
  /// if loadDotLottieFile {
  ///   // Loads the .lottie file asynchronously
  ///   animationView = LottieAnimationView(dotLottieName: "animation")
  /// } else {
  ///   // Loads the .json file synchronously
  ///   animationView = LottieAnimationView(name: "animation")
  /// }
  ///
  /// animationView.animationLoaded = { animationView, animation in
  ///   // If using a .lottie file, this is called once the file finishes loading.
  ///   // If using a .json file, this is called immediately (since the animation is loaded synchronously).
  ///   animationView.play()
  /// }
  /// ```
  public var animationLoaded: ((_ animationView: LottieAnimationView, _ animation: LottieAnimation) -> Void)? {
    didSet {
      if let animation = animation {
        animationLoaded?(self, animation)
      }
    }
  }

  /// Sets the image provider for the animation view. An image provider provides the
  /// animation with its required image data.
  ///
  /// Setting this will cause the animation to reload its image contents.
  public var imageProvider: AnimationImageProvider {
    didSet {
      animationLayer?.imageProvider = imageProvider.cachedImageProvider
      reloadImages()
    }
  }

  /// Sets the text provider for animation view. A text provider provides the
  /// animation with values for text layers
  public var textProvider: AnimationTextProvider {
    didSet {
      animationLayer?.textProvider = textProvider
    }
  }

  /// Sets the text provider for animation view. A text provider provides the
  /// animation with values for text layers
  public var fontProvider: AnimationFontProvider {
    didSet {
      animationLayer?.fontProvider = fontProvider
    }
  }

  /// Whether or not the animation is masked to the bounds. Defaults to true.
  public var maskAnimationToBounds = true {
    didSet {
      animationLayer?.masksToBounds = maskAnimationToBounds
    }
  }

  /// Returns `true` if the animation is currently playing.
  public var isAnimationPlaying: Bool {
    guard let animationLayer = animationLayer else {
      return false
    }

    if let valueFromLayer = animationLayer.isAnimationPlaying {
      return valueFromLayer
    } else {
      return animationLayer.animation(forKey: activeAnimationName) != nil
    }
  }

  /// Returns `true` if the animation will start playing when this view is added to a window.
  public var isAnimationQueued: Bool {
    animationContext != nil && waitingToPlayAnimation
  }

  /// Sets the loop behavior for `play` calls. Defaults to `playOnce`
  public var loopMode: LottieLoopMode = .playOnce {
    didSet {
      updateInFlightAnimation()
    }
  }

  /// When `true` the animation view will rasterize its contents when not animating.
  /// Rasterizing will improve performance of static animations.
  ///
  /// Note: this will not produce crisp results at resolutions above the animations natural resolution.
  ///
  /// Defaults to `false`
  public var shouldRasterizeWhenIdle = false {
    didSet {
      updateRasterizationState()
    }
  }

  /// Sets the current animation time with a Progress Time
  ///
  /// Note: Setting this will stop the current animation, if any.
  /// Note 2: If `animation` is nil, setting this will fallback to 0
  public var currentProgress: AnimationProgressTime {
    set {
      if let animation = animation {
        currentFrame = animation.frameTime(forProgress: newValue)
      } else {
        currentFrame = 0
      }
    }
    get {
      if let animation = animation {
        return animation.progressTime(forFrame: currentFrame)
      } else {
        return 0
      }
    }
  }

  /// Sets the current animation time with a time in seconds.
  ///
  /// Note: Setting this will stop the current animation, if any.
  /// Note 2: If `animation` is nil, setting this will fallback to 0
  public var currentTime: TimeInterval {
    set {
      if let animation = animation {
        currentFrame = animation.frameTime(forTime: newValue)
      } else {
        currentFrame = 0
      }
    }
    get {
      if let animation = animation {
        return animation.time(forFrame: currentFrame)
      } else {
        return 0
      }
    }
  }

  /// Sets the current animation time with a frame in the animations framerate.
  ///
  /// Note: Setting this will stop the current animation, if any.
  public var currentFrame: AnimationFrameTime {
    set {
      removeCurrentAnimationIfNecessary()
      updateAnimationFrame(newValue)
    }
    get {
      animationLayer?.currentFrame ?? 0
    }
  }

  /// Returns the current animation frame while an animation is playing.
  public var realtimeAnimationFrame: AnimationFrameTime {
    isAnimationPlaying ? animationLayer?.presentation()?.currentFrame ?? currentFrame : currentFrame
  }

  /// Returns the current animation frame while an animation is playing.
  public var realtimeAnimationProgress: AnimationProgressTime {
    if let animation = animation {
      return animation.progressTime(forFrame: realtimeAnimationFrame)
    }
    return 0
  }

  /// Sets the speed of the animation playback. Defaults to 1
  public var animationSpeed: CGFloat = 1 {
    didSet {
      updateInFlightAnimation()
    }
  }

  /// When `true` the animation will play back at the framerate encoded in the
  /// `LottieAnimation` model. When `false` the animation will play at the framerate
  /// of the device.
  ///
  /// Defaults to false
  public var respectAnimationFrameRate = false {
    didSet {
      animationLayer?.respectAnimationFrameRate = respectAnimationFrameRate
    }
  }

  /// Controls the cropping of an Animation. Setting this property will crop the animation
  /// to the current views bounds by the viewport frame. The coordinate space is specified
  /// in the animation's coordinate space.
  ///
  /// Animatable.
  public var viewportFrame: CGRect? = nil {
    didSet {
      // This is really ugly, but is needed to trigger a layout pass within an animation block.
      // Typically this happens automatically, when layout objects are UIView based.
      // The animation layer is a CALayer which will not implicitly grab the animation
      // duration of a UIView animation block.
      //
      // By setting bounds and then resetting bounds the UIView animation block's
      // duration and curve are captured and added to the layer. This is used in the
      // layout block to animate the animationLayer's position and size.
      let rect = bounds
      self.bounds = CGRect.zero
      self.bounds = rect
      self.setNeedsLayout()
    }
  }

  override public var intrinsicContentSize: CGSize {
    if let animation = animation {
      return animation.bounds.size
    }
    return .zero
  }

  /// The rendering engine currently being used by this view.
  ///  - This will only be `nil` in cases where the configuration is `automatic`
  ///    but a `RootAnimationLayer` hasn't been constructed yet
  public var currentRenderingEngine: RenderingEngine? {
    switch configuration.renderingEngine {
    case .specific(let engine):
      return engine

    case .automatic:
      guard let animationLayer = animationLayer else {
        return nil
      }

      if animationLayer is CoreAnimationLayer {
        return .coreAnimation
      } else {
        return .mainThread
      }
    }
  }

  /// Sets the lottie file backing the animation view. Setting this will clear the
  /// view's contents, completion blocks and current state. The new animation will
  /// be loaded up and set to the beginning of its timeline.
  /// The loopMode, animationSpeed and imageProvider will be set according
  /// to lottie file settings
  /// - Parameters:
  ///   - animationId: Internal animation id to play. Optional
  ///   Defaults to play first animation in file.
  ///   - dotLottieFile: Lottie file to play
  public func loadAnimation(
    _ animationId: String? = nil,
    from dotLottieFile: DotLottieFile)
  {
    guard let dotLottieAnimation = dotLottieFile.animation(for: animationId) else { return }

    loopMode = dotLottieAnimation.configuration.loopMode
    animationSpeed = CGFloat(dotLottieAnimation.configuration.speed)

    if let imageProvider = dotLottieAnimation.configuration.imageProvider {
      self.imageProvider = imageProvider
    }

    animation = dotLottieAnimation.animation
  }

  /// Reloads the images supplied to the animation from the `imageProvider`
  public func reloadImages() {
    animationLayer?.reloadImages()
  }

  /// Forces the LottieAnimationView to redraw its contents.
  public func forceDisplayUpdate() {
    animationLayer?.forceDisplayUpdate()
  }

  /// Sets a ValueProvider for the specified keypath. The value provider will be set
  /// on all properties that match the keypath.
  ///
  /// Nearly all properties of a Lottie animation can be changed at runtime using a
  /// combination of `Animation Keypaths` and `Value Providers`.
  /// Setting a ValueProvider on a keypath will cause the animation to update its
  /// contents and read the new Value Provider.
  ///
  /// A value provider provides a typed value on a frame by frame basis.
  ///
  /// - Parameter valueProvider: The new value provider for the properties.
  /// - Parameter keypath: The keypath used to search for properties.
  ///
  /// Example:
  /// ```
  /// /// A keypath that finds the color value for all `Fill 1` nodes.
  /// let fillKeypath = AnimationKeypath(keypath: "**.Fill 1.Color")
  /// /// A Color Value provider that returns a reddish color.
  /// let redValueProvider = ColorValueProvider(Color(r: 1, g: 0.2, b: 0.3, a: 1))
  /// /// Set the provider on the animationView.
  /// animationView.setValueProvider(redValueProvider, keypath: fillKeypath)
  /// ```
  public func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    guard let animationLayer = animationLayer else { return }

    valueProviders[keypath] = valueProvider
    animationLayer.setValueProvider(valueProvider, keypath: keypath)
  }

  /// Reads the value of a property specified by the Keypath.
  /// Returns nil if no property is found.
  ///
  /// - Parameter for: The keypath used to search for the property.
  /// - Parameter atFrame: The Frame Time of the value to query. If nil then the current frame is used.
  public func getValue(for keypath: AnimationKeypath, atFrame: AnimationFrameTime?) -> Any? {
    animationLayer?.getValue(for: keypath, atFrame: atFrame)
  }

  /// Reads the original value of a property specified by the Keypath.
  /// This will ignore any value providers and can be useful when implementing a value providers that makes change to the original value from the animation.
  /// Returns nil if no property is found.
  ///
  /// - Parameter for: The keypath used to search for the property.
  /// - Parameter atFrame: The Frame Time of the value to query. If nil then the current frame is used.
  public func getOriginalValue(for keypath: AnimationKeypath, atFrame: AnimationFrameTime?) -> Any? {
    animationLayer?.getOriginalValue(for: keypath, atFrame: atFrame)
  }

  /// Logs all child keypaths.
  /// Logs the result of `allHierarchyKeypaths()` to the `LottieLogger`.
  public func logHierarchyKeypaths() {
    animationLayer?.logHierarchyKeypaths()
  }

  /// Computes and returns a list of all child keypaths in the current animation.
  /// The returned list is the same as the log output of `logHierarchyKeypaths()`
  public func allHierarchyKeypaths() -> [String] {
    animationLayer?.allHierarchyKeypaths() ?? []
  }

  /// Searches for the nearest child layer to the first Keypath and adds the subview
  /// to that layer. The subview will move and animate with the child layer.
  /// Furthermore the subview will be in the child layers coordinate space.
  ///
  /// Note: if no layer is found for the keypath, then nothing happens.
  ///
  /// - Parameter subview: The subview to add to the found animation layer.
  /// - Parameter keypath: The keypath used to find the animation layer.
  ///
  /// Example:
  /// ```
  /// /// A keypath that finds `Layer 1`
  /// let layerKeypath = AnimationKeypath(keypath: "Layer 1")
  ///
  /// /// Wrap the custom view in an `AnimationSubview`
  /// let subview = AnimationSubview()
  /// subview.addSubview(customView)
  ///
  /// /// Set the provider on the animationView.
  /// animationView.addSubview(subview, forLayerAt: layerKeypath)
  /// ```
  public func addSubview(_ subview: AnimationSubview, forLayerAt keypath: AnimationKeypath) {
    guard let sublayer = animationLayer?.layer(for: keypath) else {
      return
    }
    setNeedsLayout()
    layoutIfNeeded()
    forceDisplayUpdate()
    addSubview(subview)
    if let subViewLayer = subview.viewLayer {
      sublayer.addSublayer(subViewLayer)
    }
  }

  /// Converts a CGRect from the LottieAnimationView's coordinate space into the
  /// coordinate space of the layer found at Keypath.
  ///
  /// If no layer is found, nil is returned
  ///
  /// - Parameter rect: The CGRect to convert.
  /// - Parameter toLayerAt: The keypath used to find the layer.
  public func convert(_ rect: CGRect, toLayerAt keypath: AnimationKeypath?) -> CGRect? {
    guard let animationLayer = animationLayer else { return nil }
    guard let keypath = keypath else {
      return viewLayer?.convert(rect, to: animationLayer)
    }
    guard let sublayer = animationLayer.layer(for: keypath) else {
      return nil
    }
    setNeedsLayout()
    layoutIfNeeded()
    forceDisplayUpdate()
    return animationLayer.convert(rect, to: sublayer)
  }

  /// Converts a CGPoint from the LottieAnimationView's coordinate space into the
  /// coordinate space of the layer found at Keypath.
  ///
  /// If no layer is found, nil is returned
  ///
  /// - Parameter point: The CGPoint to convert.
  /// - Parameter toLayerAt: The keypath used to find the layer.
  public func convert(_ point: CGPoint, toLayerAt keypath: AnimationKeypath?) -> CGPoint? {
    guard let animationLayer = animationLayer else { return nil }
    guard let keypath = keypath else {
      return viewLayer?.convert(point, to: animationLayer)
    }
    guard let sublayer = animationLayer.layer(for: keypath) else {
      return nil
    }
    setNeedsLayout()
    layoutIfNeeded()
    forceDisplayUpdate()
    return animationLayer.convert(point, to: sublayer)
  }

  /// Sets the enabled state of all animator nodes found with the keypath search.
  /// This can be used to interactively enable / disable parts of the animation.
  ///
  /// - Parameter isEnabled: When true the animator nodes affect the rendering tree. When false the node is removed from the tree.
  /// - Parameter keypath: The keypath used to find the node(s).
  public func setNodeIsEnabled(isEnabled: Bool, keypath: AnimationKeypath) {
    guard let animationLayer = animationLayer else { return }
    let nodes = animationLayer.animatorNodes(for: keypath)
    if let nodes = nodes {
      for node in nodes {
        node.isEnabled = isEnabled
      }
      forceDisplayUpdate()
    }
  }

  /// Markers are a way to describe a point in time by a key name.
  ///
  /// Markers are encoded into animation JSON. By using markers a designer can mark
  /// playback points for a developer to use without having to worry about keeping
  /// track of animation frames. If the animation file is updated, the developer
  /// does not need to update playback code.
  ///
  /// Returns the Progress Time for the marker named. Returns nil if no marker found.
  public func progressTime(forMarker named: String) -> AnimationProgressTime? {
    guard let animation = animation else {
      return nil
    }
    return animation.progressTime(forMarker: named)
  }

  /// Markers are a way to describe a point in time by a key name.
  ///
  /// Markers are encoded into animation JSON. By using markers a designer can mark
  /// playback points for a developer to use without having to worry about keeping
  /// track of animation frames. If the animation file is updated, the developer
  /// does not need to update playback code.
  ///
  /// Returns the Frame Time for the marker named. Returns nil if no marker found.
  public func frameTime(forMarker named: String) -> AnimationFrameTime? {
    guard let animation = animation else {
      return nil
    }
    return animation.frameTime(forMarker: named)
  }

  /// Markers are a way to describe a point in time and a duration by a key name.
  ///
  /// Markers are encoded into animation JSON. By using markers a designer can mark
  /// playback points for a developer to use without having to worry about keeping
  /// track of animation frames. If the animation file is updated, the developer
  /// does not need to update playback code.
  ///
  /// - Returns: The duration frame time for the marker, or `nil` if no marker found.
  public func durationFrameTime(forMarker named: String) -> AnimationFrameTime? {
    guard let animation = animation else {
      return nil
    }
    return animation.durationFrameTime(forMarker: named)
  }

  // MARK: Internal

  var animationLayer: RootAnimationLayer? = nil

  /// Set animation name from Interface Builder
  @IBInspectable var animationName: String? {
    didSet {
      self.animation = animationName.flatMap {
        LottieAnimation.named($0, animationCache: nil)
      }
    }
  }

  override func layoutAnimation() {
    guard let animation = animation, let animationLayer = animationLayer else { return }
    var position = animation.bounds.center
    let xform: CATransform3D
    var shouldForceUpdates = false

    if let viewportFrame = viewportFrame {
      shouldForceUpdates = contentMode == .redraw

      let compAspect = viewportFrame.size.width / viewportFrame.size.height
      let viewAspect = bounds.size.width / bounds.size.height
      let dominantDimension = compAspect > viewAspect ? bounds.size.width : bounds.size.height
      let compDimension = compAspect > viewAspect ? viewportFrame.size.width : viewportFrame.size.height
      let scale = dominantDimension / compDimension

      let viewportOffset = animation.bounds.center - viewportFrame.center
      xform = CATransform3DTranslate(CATransform3DMakeScale(scale, scale, 1), viewportOffset.x, viewportOffset.y, 0)
      position = bounds.center
    } else {
      switch contentMode {
      case .scaleToFill:
        position = bounds.center
        xform = CATransform3DMakeScale(
          bounds.size.width / animation.size.width,
          bounds.size.height / animation.size.height,
          1);
      case .scaleAspectFit:
        position = bounds.center
        let compAspect = animation.size.width / animation.size.height
        let viewAspect = bounds.size.width / bounds.size.height
        let dominantDimension = compAspect > viewAspect ? bounds.size.width : bounds.size.height
        let compDimension = compAspect > viewAspect ? animation.size.width : animation.size.height
        let scale = dominantDimension / compDimension
        xform = CATransform3DMakeScale(scale, scale, 1)
      case .scaleAspectFill:
        position = bounds.center
        let compAspect = animation.size.width / animation.size.height
        let viewAspect = bounds.size.width / bounds.size.height
        let scaleWidth = compAspect < viewAspect
        let dominantDimension = scaleWidth ? bounds.size.width : bounds.size.height
        let compDimension = scaleWidth ? animation.size.width : animation.size.height
        let scale = dominantDimension / compDimension
        xform = CATransform3DMakeScale(scale, scale, 1)
      case .redraw:
        shouldForceUpdates = true
        xform = CATransform3DIdentity
      case .center:
        position = bounds.center
        xform = CATransform3DIdentity
      case .top:
        position.x = bounds.center.x
        xform = CATransform3DIdentity
      case .bottom:
        position.x = bounds.center.x
        position.y = bounds.maxY - animation.bounds.midY
        xform = CATransform3DIdentity
      case .left:
        position.y = bounds.center.y
        xform = CATransform3DIdentity
      case .right:
        position.y = bounds.center.y
        position.x = bounds.maxX - animation.bounds.midX
        xform = CATransform3DIdentity
      case .topLeft:
        xform = CATransform3DIdentity
      case .topRight:
        position.x = bounds.maxX - animation.bounds.midX
        xform = CATransform3DIdentity
      case .bottomLeft:
        position.y = bounds.maxY - animation.bounds.midY
        xform = CATransform3DIdentity
      case .bottomRight:
        position.x = bounds.maxX - animation.bounds.midX
        position.y = bounds.maxY - animation.bounds.midY
        xform = CATransform3DIdentity

      #if os(iOS) || os(tvOS)
      @unknown default:
        logger.assertionFailure("unsupported contentMode: \(contentMode.rawValue)")
        xform = CATransform3DIdentity
      #endif
      }
    }

    // UIView Animation does not implicitly set CAAnimation time or timing fuctions.
    // If layout is changed in an animation we must get the current animation duration
    // and timing function and then manually create a CAAnimation to match the UIView animation.
    // If layout is changed without animation, explicitly set animation duration to 0.0
    // inside CATransaction to avoid unwanted artifacts.
    /// Check if any animation exist on the view's layer, and match it.
    if let key = viewLayer?.animationKeys()?.first, let animation = viewLayer?.animation(forKey: key) {
      // The layout is happening within an animation block. Grab the animation data.

      let positionKey = "LayoutPositionAnimation"
      let transformKey = "LayoutTransformAnimation"
      animationLayer.removeAnimation(forKey: positionKey)
      animationLayer.removeAnimation(forKey: transformKey)

      let positionAnimation = animation.copy() as? CABasicAnimation ?? CABasicAnimation(keyPath: "position")
      positionAnimation.keyPath = "position"
      positionAnimation.isAdditive = false
      positionAnimation.fromValue = (animationLayer.presentation() ?? animationLayer).position
      positionAnimation.toValue = position
      positionAnimation.isRemovedOnCompletion = true

      let xformAnimation = animation.copy() as? CABasicAnimation ?? CABasicAnimation(keyPath: "transform")
      xformAnimation.keyPath = "transform"
      xformAnimation.isAdditive = false
      xformAnimation.fromValue = (animationLayer.presentation() ?? animationLayer).transform
      xformAnimation.toValue = xform
      xformAnimation.isRemovedOnCompletion = true

      animationLayer.position = position
      animationLayer.transform = xform
      #if os(OSX)
      animationLayer.anchorPoint = layer?.anchorPoint ?? CGPoint.zero
      #else
      animationLayer.anchorPoint = layer.anchorPoint
      #endif
      animationLayer.add(positionAnimation, forKey: positionKey)
      animationLayer.add(xformAnimation, forKey: transformKey)
    } else {
      // In performance tests, we have to wrap the animation view setup
      // in a `CATransaction` in order for the layers to be deallocated at
      // the correct time. The `CATransaction`s in this method interfere
      // with the ones managed by the performance test, and aren't actually
      // necessary in a headless environment, so we disable them.
      if TestHelpers.performanceTestsAreRunning {
        animationLayer.position = position
        animationLayer.transform = xform
      } else {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
        animationLayer.position = position
        animationLayer.transform = xform
        CATransaction.commit()
      }
    }

    if shouldForceUpdates {
      animationLayer.forceDisplayUpdate()
    }
  }

  func updateRasterizationState() {
    if isAnimationPlaying {
      animationLayer?.shouldRasterize = false
    } else {
      animationLayer?.shouldRasterize = shouldRasterizeWhenIdle
    }
  }

  /// Updates the animation frame. Does not affect any current animations
  func updateAnimationFrame(_ newFrame: CGFloat) {
    // In performance tests, we have to wrap the animation view setup
    // in a `CATransaction` in order for the layers to be deallocated at
    // the correct time. The `CATransaction`s in this method interfere
    // with the ones managed by the performance test, and aren't actually
    // necessary in a headless environment, so we disable them.
    if TestHelpers.performanceTestsAreRunning {
      animationLayer?.currentFrame = newFrame
      animationLayer?.forceDisplayUpdate()
      return
    }

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.animationLayer?.forceDisplayUpdate()
    }
    CATransaction.setDisableActions(true)
    animationLayer?.currentFrame = newFrame
    CATransaction.commit()
  }

  @objc
  override func animationWillMoveToBackground() {
    updateAnimationForBackgroundState()
  }

  @objc
  override func animationWillEnterForeground() {
    updateAnimationForForegroundState()
  }

  override func animationMovedToWindow() {
    /// Don't update any state if the `superview`  is `nil`
    /// When A viewA owns superViewB, it removes the superViewB from the window. At this point, viewA still owns superViewB and triggers the viewA method: -didmovetowindow
    guard superview != nil else { return }

    if window != nil {
      updateAnimationForForegroundState()
    } else {
      updateAnimationForBackgroundState()
    }
  }

  /// Updates an in flight animation.
  func updateInFlightAnimation() {
    guard let animationContext = animationContext else { return }

    guard animationContext.closure.animationState != .complete else {
      // Tried to re-add an already completed animation. Cancel.
      self.animationContext = nil
      return
    }

    /// Tell existing context to ignore its closure
    animationContext.closure.ignoreDelegate = true

    /// Make a new context, stealing the completion block from the previous.
    let newContext = AnimationContext(
      playFrom: animationContext.playFrom,
      playTo: animationContext.playTo,
      closure: animationContext.closure.completionBlock)

    /// Remove current animation, and freeze the current frame.
    let pauseFrame = realtimeAnimationFrame
    animationLayer?.removeAnimation(forKey: activeAnimationName)
    animationLayer?.currentFrame = pauseFrame

    addNewAnimationForContext(newContext)
  }

  // MARK: Fileprivate

  /// Context describing the animation that is currently playing in this `LottieAnimationView`
  ///  - When non-nil, an animation is currently playing in this view. Otherwise,
  ///    the view is paused on a specific frame.
  fileprivate var animationContext: AnimationContext?

  fileprivate var _activeAnimationName: String = LottieAnimationView.animationName
  fileprivate var animationID = 0

  fileprivate var waitingToPlayAnimation = false

  fileprivate var activeAnimationName: String {
    switch animationLayer?.primaryAnimationKey {
    case .specific(let animationKey):
      return animationKey
    case .managed, nil:
      return _activeAnimationName
    }
  }

  fileprivate func makeAnimationLayer(usingEngine renderingEngine: RenderingEngineOption) {
    /// Remove current animation if any
    removeCurrentAnimation()

    if let oldAnimation = animationLayer {
      oldAnimation.removeFromSuperlayer()
      animationLayer = nil
    }

    invalidateIntrinsicContentSize()

    guard let animation = animation else {
      return
    }

    let rootAnimationLayer: RootAnimationLayer?
    switch renderingEngine {
    case .automatic:
      rootAnimationLayer = makeAutomaticEngineLayer(for: animation)
    case .specific(.coreAnimation):
      rootAnimationLayer = makeCoreAnimationLayer(for: animation)
    case .specific(.mainThread):
      rootAnimationLayer = makeMainThreadAnimationLayer(for: animation)
    }

    guard let animationLayer = rootAnimationLayer else {
      return
    }

    animationLayer.animationView = self
    animationLayer.renderScale = screenScale

    viewLayer?.addSublayer(animationLayer)
    self.animationLayer = animationLayer
    reloadImages()
    animationLayer.setNeedsDisplay()
    setNeedsLayout()
    currentFrame = CGFloat(animation.startFrame)
  }

  fileprivate func makeMainThreadAnimationLayer(for animation: LottieAnimation) -> MainThreadAnimationLayer {
    MainThreadAnimationLayer(
      animation: animation,
      imageProvider: imageProvider.cachedImageProvider,
      textProvider: textProvider,
      fontProvider: fontProvider,
      maskAnimationToBounds: maskAnimationToBounds,
      logger: logger)
  }

  fileprivate func makeCoreAnimationLayer(for animation: LottieAnimation) -> CoreAnimationLayer? {
    do {
      let coreAnimationLayer = try CoreAnimationLayer(
        animation: animation,
        imageProvider: imageProvider.cachedImageProvider,
        textProvider: textProvider,
        fontProvider: fontProvider,
        maskAnimationToBounds: maskAnimationToBounds,
        compatibilityTrackerMode: .track,
        logger: logger)

      coreAnimationLayer.didSetUpAnimation = { [logger] compatibilityIssues in
        logger.assert(
          compatibilityIssues.isEmpty,
          "Encountered Core Animation compatibility issues while setting up animation:\n"
            + compatibilityIssues.map { $0.description }.joined(separator: "\n") + "\n\n"
            + """
              This animation cannot be rendered correctly by the Core Animation engine.
              To resolve this issue, you can use `RenderingEngineOption.automatic`, which automatically falls back
              to the Main Thread rendering engine when necessary, or just use `RenderingEngineOption.mainThread`.

              """)
      }

      return coreAnimationLayer
    } catch {
      // This should never happen, because we initialize the `CoreAnimationLayer` with
      // `CompatibilityTracker.Mode.track` (which reports errors in `didSetUpAnimation`,
      // not by throwing).
      logger.assertionFailure("Encountered unexpected error \(error)")
      return nil
    }
  }

  fileprivate func makeAutomaticEngineLayer(for animation: LottieAnimation) -> CoreAnimationLayer? {
    do {
      // Attempt to set up the Core Animation layer. This can either throw immediately in `init`,
      // or throw an error later in `CALayer.display()` that will be reported in `didSetUpAnimation`.
      let coreAnimationLayer = try CoreAnimationLayer(
        animation: animation,
        imageProvider: imageProvider.cachedImageProvider,
        textProvider: textProvider,
        fontProvider: fontProvider,
        maskAnimationToBounds: maskAnimationToBounds,
        compatibilityTrackerMode: .abort,
        logger: logger)

      coreAnimationLayer.didSetUpAnimation = { [weak self] issues in
        self?.automaticEngineLayerDidSetUpAnimation(issues)
      }

      return coreAnimationLayer
    } catch {
      if case CompatibilityTracker.Error.encounteredCompatibilityIssue(let compatibilityIssue) = error {
        automaticEngineLayerDidSetUpAnimation([compatibilityIssue])
      } else {
        // This should never happen, because we expect `CoreAnimationLayer` to only throw
        // `CompatibilityTracker.Error.encounteredCompatibilityIssue` errors.
        logger.assertionFailure("Encountered unexpected error \(error)")
        automaticEngineLayerDidSetUpAnimation([])
      }

      return nil
    }
  }

  // Handles any compatibility issues with the Core Animation engine
  // by falling back to the Main Thread engine
  fileprivate func automaticEngineLayerDidSetUpAnimation(_ compatibilityIssues: [CompatibilityIssue]) {
    // If there weren't any compatibility issues, then there's nothing else to do
    if compatibilityIssues.isEmpty {
      return
    }

    logger.warn(
      "Encountered Core Animation compatibility issue while setting up animation:\n"
        + compatibilityIssues.map { $0.description }.joined(separator: "\n") + "\n"
        + """
          This animation may have additional compatibility issues, but animation setup was cancelled early to avoid wasted work.

          Automatically falling back to Main Thread rendering engine. This fallback comes with some additional performance
          overhead, which can be reduced by manually specifying that this animation should always use the Main Thread engine.

          """)

    let animationContext = animationContext
    let currentFrame = currentFrame

    // Disable the completion handler delegate before tearing down the `CoreAnimationLayer`
    // and building the `MainThreadAnimationLayer`. Otherwise deinitializing the
    // `CoreAnimationLayer` would trigger the animation completion handler even though
    // the animation hasn't even started playing yet.
    animationContext?.closure.ignoreDelegate = true

    makeAnimationLayer(usingEngine: .mainThread)

    // Set up the Main Thread animation layer using the same configuration that
    // was being used by the previous Core Animation layer
    self.currentFrame = currentFrame

    if let animationContext = animationContext {
      // `AnimationContext.closure` (`AnimationCompletionDelegate`) is a reference type
      // that is the animation layer's `CAAnimationDelegate`, and holds a reference to
      // the animation layer. Reusing a single instance across different animation layers
      // can cause the animation setup to fail, so we create a copy of the `animationContext`:
      addNewAnimationForContext(AnimationContext(
        playFrom: animationContext.playFrom,
        playTo: animationContext.playTo,
        closure: animationContext.closure.completionBlock))
    }
  }

  fileprivate func updateAnimationForBackgroundState() {
    if let currentContext = animationContext {
      switch backgroundBehavior {
      case .stop:
        removeCurrentAnimation()
        updateAnimationFrame(currentContext.playFrom)
      case .pause:
        removeCurrentAnimation()
      case .pauseAndRestore:
        currentContext.closure.ignoreDelegate = true
        removeCurrentAnimation()
        /// Keep the stale context around for when the app enters the foreground.
        animationContext = currentContext
      case .forceFinish:
        removeCurrentAnimation()
        updateAnimationFrame(currentContext.playTo)
      case .continuePlaying:
        break
      }
    }
  }

  fileprivate func updateAnimationForForegroundState() {
    if let currentContext = animationContext {
      if waitingToPlayAnimation {
        waitingToPlayAnimation = false
        addNewAnimationForContext(currentContext)
      } else if backgroundBehavior == .pauseAndRestore {
        /// Restore animation from saved state
        updateInFlightAnimation()
      }
    }
  }

  /// Removes the current animation and pauses the animation at the current frame
  /// if necessary before setting up a new animation.
  ///  - This is not necessary with the Core Animation engine, and skipping
  ///    this step lets us avoid building the animations twice (once paused
  ///    and once again playing)
  ///  - This method should only be called immediately before setting up another
  ///    animation -- otherwise this LottieAnimationView could be put in an inconsistent state.
  fileprivate func removeCurrentAnimationIfNecessary() {
    switch currentRenderingEngine {
    case .mainThread:
      removeCurrentAnimation()
    case .coreAnimation, nil:
      // We still need to remove the `animationContext`, since it should only be present
      // when an animation is actually playing. Without this calling `removeCurrentAnimationIfNecessary()`
      // and then setting the animation to a specific paused frame would put this
      // `LottieAnimationView` in an inconsistent state.
      animationContext = nil
    }
  }

  /// Stops the current in flight animation and freezes the animation in its current state.
  fileprivate func removeCurrentAnimation() {
    guard animationContext != nil else { return }
    let pauseFrame = realtimeAnimationFrame
    animationLayer?.removeAnimation(forKey: activeAnimationName)
    updateAnimationFrame(pauseFrame)
    animationContext = nil
  }

  /// Adds animation to animation layer and sets the delegate. If animation layer or animation are nil, exits.
  fileprivate func addNewAnimationForContext(_ animationContext: AnimationContext) {
    guard let animationlayer = animationLayer, let animation = animation else {
      return
    }

    self.animationContext = animationContext

    switch currentRenderingEngine {
    case .mainThread:
      guard window != nil else {
        waitingToPlayAnimation = true
        return
      }

    case .coreAnimation, nil:
      // The Core Animation engine automatically batches animation setup to happen
      // in `CALayer.display()`, which won't be called until the layer is on-screen,
      // so we don't need to defer animation setup at this layer.
      break
    }

    animationID = animationID + 1
    _activeAnimationName = LottieAnimationView.animationName + String(animationID)

    if let coreAnimationLayer = animationlayer as? CoreAnimationLayer {
      var animationContext = animationContext

      // Core Animation doesn't natively support negative speed values,
      // so instead we can swap `playFrom` / `playTo`
      if animationSpeed < 0 {
        let temp = animationContext.playFrom
        animationContext.playFrom = animationContext.playTo
        animationContext.playTo = temp
      }

      var timingConfiguration = CoreAnimationLayer.CAMediaTimingConfiguration(
        autoreverses: loopMode.caAnimationConfiguration.autoreverses,
        repeatCount: loopMode.caAnimationConfiguration.repeatCount,
        speed: abs(Float(animationSpeed)))

      // The animation should start playing from the `currentFrame`,
      // if `currentFrame` is included in the time range being played.
      let lowerBoundTime = min(animationContext.playFrom, animationContext.playTo)
      let upperBoundTime = max(animationContext.playFrom, animationContext.playTo)
      if (lowerBoundTime ..< upperBoundTime).contains(round(currentFrame)) {
        // We have to configure this differently depending on the loop mode:
        switch loopMode {
        // When playing exactly once (and not looping), we can just set the
        // `playFrom` time to be the `currentFrame`. Since the animation duration
        // is based on `playFrom` and `playTo`, this automatically truncates the
        // duration (so the animation stops playing at `playFrom`).
        //  - Don't do this if the animation is already at that frame
        //    (e.g. playing from 100% to 0% when the animation is already at 0%)
        //    since that would cause the animation to not play at all.
        case .playOnce:
          if animationContext.playTo != currentFrame {
            animationContext.playFrom = currentFrame
          }

        // When looping, we specifically _don't_ want to affect the duration of the animation,
        // since that would affect the duration of all subsequent loops. We just want to adjust
        // the duration of the _first_ loop. Instead of setting `playFrom`, we just add a `timeOffset`
        // so the first loop begins at `currentTime` but all subsequent loops are the standard duration.
        default:
          if animationSpeed < 0 {
            timingConfiguration.timeOffset = animation.time(forFrame: animationContext.playFrom) - currentTime
          } else {
            timingConfiguration.timeOffset = currentTime - animation.time(forFrame: animationContext.playFrom)
          }
        }
      }

      // If attempting to play a zero-duration animation, just pause on that single frame instead
      if animationContext.playFrom == animationContext.playTo {
        currentFrame = animationContext.playTo
        animationContext.closure.completionBlock?(true)
        return
      }

      coreAnimationLayer.playAnimation(configuration: .init(
        animationContext: animationContext,
        timingConfiguration: timingConfiguration))

      return
    }

    /// At this point there is no animation on animationLayer and its state is set.

    let framerate = animation.framerate

    let playFrom = animationContext.playFrom.clamp(animation.startFrame, animation.endFrame)
    let playTo = animationContext.playTo.clamp(animation.startFrame, animation.endFrame)

    let duration = ((max(playFrom, playTo) - min(playFrom, playTo)) / CGFloat(framerate))

    let playingForward: Bool =
      (
        (animationSpeed > 0 && playFrom < playTo) ||
          (animationSpeed < 0 && playTo < playFrom))

    var startFrame = currentFrame.clamp(min(playFrom, playTo), max(playFrom, playTo))
    if startFrame == playTo {
      startFrame = playFrom
    }

    let timeOffset: TimeInterval = playingForward
      ? Double(startFrame - min(playFrom, playTo)) / framerate
      : Double(max(playFrom, playTo) - startFrame) / framerate

    let layerAnimation = CABasicAnimation(keyPath: "currentFrame")
    layerAnimation.fromValue = playFrom
    layerAnimation.toValue = playTo
    layerAnimation.speed = Float(animationSpeed)
    layerAnimation.duration = TimeInterval(duration)
    layerAnimation.fillMode = CAMediaTimingFillMode.both
    layerAnimation.repeatCount = loopMode.caAnimationConfiguration.repeatCount
    layerAnimation.autoreverses = loopMode.caAnimationConfiguration.autoreverses

    layerAnimation.isRemovedOnCompletion = false
    if timeOffset != 0 {
      let currentLayerTime = viewLayer?.convertTime(CACurrentMediaTime(), from: nil) ?? 0
      layerAnimation.beginTime = currentLayerTime - (timeOffset * 1 / Double(abs(animationSpeed)))
    }
    layerAnimation.delegate = animationContext.closure
    animationContext.closure.animationLayer = animationlayer
    animationContext.closure.animationKey = activeAnimationName

    animationlayer.add(layerAnimation, forKey: activeAnimationName)
    updateRasterizationState()
  }

  // MARK: Private

  static private let animationName = "Lottie"

  private let logger: LottieLogger

  /// The `LottieBackgroundBehavior` that was specified manually by setting `self.backgroundBehavior`
  private var _backgroundBehavior: LottieBackgroundBehavior?

}

// MARK: - LottieLoopMode + caAnimationConfiguration

extension LottieLoopMode {
  /// The `CAAnimation` configuration that reflects this mode
  var caAnimationConfiguration: (repeatCount: Float, autoreverses: Bool) {
    switch self {
    case .playOnce:
      return (repeatCount: 1, autoreverses: false)
    case .loop:
      return (repeatCount: .greatestFiniteMagnitude, autoreverses: false)
    case .autoReverse:
      return (repeatCount: .greatestFiniteMagnitude, autoreverses: true)
    case .repeat(let amount):
      return (repeatCount: amount, autoreverses: false)
    case .repeatBackwards(let amount):
      return (repeatCount: amount, autoreverses: true)
    }
  }
}
