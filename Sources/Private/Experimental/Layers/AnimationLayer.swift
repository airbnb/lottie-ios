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
  /// The set of `CAAnimation`s  that should be applied to this layer
  func animations(context: LayerAnimationContext) -> [CAPropertyAnimation]
}

// MARK: - LayerAnimationContext

// Context describing the timing parameters of the current animation
struct LayerAnimationContext {
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
