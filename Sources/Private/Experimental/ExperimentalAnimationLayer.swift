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
    guard let layer = layer as? Self else {
      fatalError("init(layer:) incorrectly called with \(type(of: layer))")
    }

    animation = layer.animation
    super.init(layer: layer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  /// Timing-related configuration to apply to this layer's child `CAAnimation`s
  ///  - This is effectively a configurable subset of `CAMediaTiming`
  struct TimingConfiguration {
    var autoreverses = false
    var repeatCount: Float = 0
    var speed: Float = 1
    var timeOffset: TimeInterval = 0
  }

  /// Sets up `CAAnimation`s for each `AnimationLayer` in the layer hierarchy
  func setupAnimation(timingConfiguration: TimingConfiguration) {
    self.timingConfiguration = timingConfiguration

    let context = LayerAnimationContext(
      timingConfiguration: timingConfiguration,
      startFrame: animation.startFrame,
      endFrame: animation.endFrame,
      framerate: CGFloat(animation.framerate))

    // Remove any existing animations from the layer hierarchy
    for sublayer in allSublayers {
      sublayer.removeAllAnimations()
    }

    // Perform a layout pass if necessary so all of the sublayers
    // have the most up-to-date sizing information
    layoutIfNeeded()

    // Set the speed of this layer, which will be inherited
    // by all sublayers and their animations.
    //  - This is required to support scrubbing with a speed of 0
    speed = timingConfiguration.speed

    // Set up the new animations with the current `TimingConfiguration`
    for animationLayer in animationLayers {
      animationLayer.setupAnimations(context: context)
    }
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    for animationLayer in animationLayers {
      animationLayer.fillBoundsOfSuperlayer()
    }

    // If no animation has been set up yet, display the first frame
    // now that the layer hierarchy has been setup and laid out
    if
      timingConfiguration == nil,
      bounds.size != .zero
    {
      currentFrame = animation.startFrame
    }
  }

  // MARK: Private

  /// The timing configuration that is being used for the currently-active animation
  private var timingConfiguration: TimingConfiguration?

  private let animation: Animation
  private var animationLayers = [AnimationLayer]()

  private func setup() {
    bounds = animation.bounds
  }

  private func setupChildLayers() {
    animationLayers = animation.layers.reversed().compactMap { layerModel in
      (layerModel as? LayerConstructing)?.makeLayer()
    }

    for animationLayer in animationLayers {
      addSublayer(animationLayer)
    }
  }

}

// MARK: RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var currentFrame: AnimationFrameTime {
    get {
      0 // TODO: how do we retrieve the realtime animation progress?
    }
    set {
      setupAnimation(timingConfiguration: .init(
        speed: 0,
        timeOffset: animation.time(forFrame: newValue)))
    }
  }

  var renderScale: CGFloat {
    get { 0 }
    set { fatalError("Currently unsupported") }
  }

  var respectAnimationFrameRate: Bool {
    get { false }
    set { fatalError("Currently unsupported") }
  }

  var _animationLayers: [CALayer] {
    animationLayers
  }

  var imageProvider: AnimationImageProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  var textProvider: AnimationTextProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  var fontProvider: AnimationFontProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  func reloadImages() {
    fatalError("Currently unsupported")
  }

  func forceDisplayUpdate() {
    // Unimplemented
  }

  func logHierarchyKeypaths() {
    fatalError("Currently unsupported")
  }

  func setValueProvider(_: AnyValueProvider, keypath _: AnimationKeypath) {
    fatalError("Currently unsupported")
  }

  func getValue(for _: AnimationKeypath, atFrame _: AnimationFrameTime?) -> Any? {
    fatalError("Currently unsupported")
  }

  func layer(for _: AnimationKeypath) -> CALayer? {
    fatalError("Currently unsupported")
  }

  func animatorNodes(for _: AnimationKeypath) -> [AnimatorNode]? {
    fatalError("Currently unsupported")
  }

}

// MARK: - CALayer + allSublayers

extension CALayer {
  /// All of the layers in the layer tree that are descendants from this later
  @nonobjc
  fileprivate var allSublayers: [CALayer] {
    var allSublayers: [CALayer] = []

    for sublayer in sublayers ?? [] {
      allSublayers.append(sublayer)
      allSublayers.append(contentsOf: sublayer.allSublayers)
    }

    return allSublayers
  }
}
