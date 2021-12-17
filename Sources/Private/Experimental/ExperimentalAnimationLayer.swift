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

  /// The timing configuration that is being used for the currently-active animation
  private var timingConfiguration: TimingConfiguration?

  /// Sets up `CAAnimation`s for each `AnimationLayer` in the layer hierarchy
  func setupAnimation(timingConfiguration: TimingConfiguration) {
    self.timingConfiguration = timingConfiguration

    let context = LayerAnimationContext(
      startFrame: animation.startFrame,
      endFrame: animation.endFrame,
      framerate: CGFloat(animation.framerate))

    // Remove any existing animations from the layer hierarchy
    for animationLayer in animationLayers {
      animationLayer.removeAllAnimations()
    }

    // Set up the new animations with the current `TimingConfiguration`
    for animationLayer in animationLayers {

      // Necessary here and not on animation (why??)
      animationLayer.speed = timingConfiguration.speed

      // TODO: instead of collecting and applying the animations here,
      // it would be nice to just build them and apply them in the subclass
      // (passing `TimingConfiguration` through the context struct)

      for caAnimation in animationLayer.animations(context: context) {
        caAnimation.duration = animation.duration

        caAnimation.repeatCount = timingConfiguration.repeatCount
        caAnimation.autoreverses = timingConfiguration.autoreverses
        caAnimation.timeOffset = timingConfiguration.timeOffset

        animationLayer.add(caAnimation, forKey: caAnimation.keyPath)
      }
    }
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    for animationLayer in animationLayers {
      animationLayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let animation: Animation
  private var animationLayers = [AnimationLayer]()

  private func setup() {
    bounds = animation.bounds
  }

  private func setupChildLayers() {
    var animationLayers = [AnimationLayer]()

    for layerModel in animation.layers.reversed() {
      if let layer = (layerModel as? LayerConstructing)?.makeLayer() {
        addSublayer(layer)
        animationLayers.append(layer)
      }

      self.animationLayers = animationLayers
    }

    self.animationLayers = animationLayers
  }

}

// MARK: RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var currentFrame: AnimationFrameTime {
    get { 0 }
    set {
      // The animation must have a speed of 0 to be scrubbed interactively
      if timingConfiguration?.speed != 0 {
        var updatedTimingConfiguration = timingConfiguration ?? .init()
        updatedTimingConfiguration.speed = 0
        setupAnimation(timingConfiguration: updatedTimingConfiguration)
      }

      let newTimeOffset = animation.time(forFrame: newValue)

      for sublayer in (sublayers ?? []) {
        sublayer.timeOffset = Double(newTimeOffset)
      }
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

extension CALayer {
  var allLayers: [CALayer] {
    var allLayers: [CALayer] = [self]

    for sublayer in (sublayers ?? []) {
      allLayers += sublayer.allLayers
    }

    return allLayers
  }

  var allSublayers: [CALayer] {
    var allSublayers: [CALayer] = []

    for sublayer in (sublayers ?? []) {
      allSublayers += [sublayer] + sublayer.allSublayers
    }

    return allSublayers
  }
}
