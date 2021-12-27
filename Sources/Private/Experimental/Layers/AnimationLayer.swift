// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerConstructing

/// A type that can construct a CALayer to display in a Lottie animation
protocol LayerConstructing {
  func makeLayer() -> AnimationLayer
}

// MARK: - AnimationLayer

/// A type of `CALayer` that can be used in a Lottie animation
protocol AnimationLayer: CALayer {
  /// Instructs this layer to setup its `CAAnimation`s
  /// using the given `LayerAnimationContext`
  func setupAnimations(context: LayerAnimationContext)
}

// MARK: - LayerAnimationContext

// Context describing the timing parameters of the current animation
struct LayerAnimationContext {
  /// The timing configuration that should be applied to `CAAnimation`s
  let timingConfiguration: ExperimentalAnimationLayer.TimingConfiguration

  /// The absolute frame number that this animation begins at
  let startFrame: AnimationFrameTime

  /// The absolute frame number that this animation ends at
  let endFrame: AnimationFrameTime

  /// The frame rate that this animation is played at
  let framerate: CGFloat

  /// The duration of this animation, in seconds
  var duration: TimeInterval {
    let frameDuration = endFrame - startFrame
    return TimeInterval(frameDuration / framerate)
  }
}

// MARK: - CAAnimation + LayerAnimationContext

extension CAAnimation {
  /// Configures the timing properties of this `CAAnimation`
  /// using the current `LayerAnimationContext`
  func configureTiming(with context: LayerAnimationContext) {
    duration = context.duration
    repeatCount = context.timingConfiguration.repeatCount
    autoreverses = context.timingConfiguration.autoreverses
    timeOffset = context.timingConfiguration.timeOffset
    isRemovedOnCompletion = false
    fillMode = .both
  }
}
