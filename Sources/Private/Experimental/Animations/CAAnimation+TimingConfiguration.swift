// Created by Cal Stephens on 1/6/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerAnimationContext

// Context describing the timing parameters of the current animation
struct LayerAnimationContext {
  /// The animation being played
  let animation: Animation

  /// The timing configuration that should be applied to `CAAnimation`s
  let timingConfiguration: ExperimentalAnimationLayer.CAMediaTimingConfiguration

  /// The absolute frame number that this animation begins at
  let startFrame: AnimationFrameTime

  /// The absolute frame number that this animation ends at
  let endFrame: AnimationFrameTime
}

// MARK: - CAAnimation + LayerAnimationContext

extension CAAnimation {
  /// Creates a `CAAnimation` that wraps this animation,
  /// applying timing-related configuration from the given `LayerAnimationContext`
  func timed(with context: LayerAnimationContext) -> CAAnimation {

    // The base animation always has the duration of the full animation,
    // since that's the time space where keyframing and interpolating happens.
    // So we start with a simple animation timeline from 0% to 100%:
    //
    //  ┌──────────────────────────────────┐
    //  │           baseAnimation          │
    //  └──────────────────────────────────┘
    //  0%                                100%
    //
    let baseAnimation = self
    baseAnimation.duration = context.animation.duration
    baseAnimation.speed = (context.endFrame < context.startFrame) ? -1 : 1

    // To select the subrange of the `baseAnimation` that should be played,
    // we create a parent animation with the duration of that subrange
    // to clip the `baseAnimation`. This parent animation can then loop
    // and/or autoreverse over the clipped subrange.
    //
    //        ┌────────────────────┬───────►
    //        │   clippingParent   │  ...
    //        └────────────────────┴───────►
    //       25%                  75%
    //  ┌──────────────────────────────────┐
    //  │           baseAnimation          │
    //  └──────────────────────────────────┘
    //  0%                                100%
    //
    let clippingParent = CAAnimationGroup()
    clippingParent.animations = [baseAnimation]

    clippingParent.duration = abs(context.animation.time(forFrame: context.endFrame - context.startFrame))
    baseAnimation.timeOffset = context.animation.time(forFrame: context.startFrame)

    clippingParent.autoreverses = context.timingConfiguration.autoreverses
    clippingParent.repeatCount = context.timingConfiguration.repeatCount
    clippingParent.timeOffset = context.timingConfiguration.timeOffset

    // Once the animation ends, it should pause on the final frame
    clippingParent.fillMode = .both
    clippingParent.isRemovedOnCompletion = false

    return clippingParent
  }
}
