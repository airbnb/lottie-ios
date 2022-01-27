// Created by Cal Stephens on 1/6/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAAnimation {
  /// Creates a `CAAnimation` that wraps this animation,
  /// applying timing-related configuration from the given `LayerAnimationContext`
  @nonobjc
  func timed(with context: LayerAnimationContext, for layer: CALayer) -> CAAnimation {

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

    // We can pause the animation on a specific frame by setting the root layer's
    // `speed` to 0, and then setting the `timeOffset` for the given frame.
    //  - For that setup to work properly, we have to set the `beginTime`
    //    of this animation to a time slightly before the current time.
    //  - It's not really clear why this is necessary, but `timeOffset`
    //    is not applied correctly without this configuration.
    //  - We can't do this when playing the animation in real time,
    //    because it can cause keyframe timings to be incorrect.
    if context.timingConfiguration.speed == 0 {
      let currentTime = layer.convertTime(CACurrentMediaTime(), from: nil)
      clippingParent.beginTime = currentTime - .leastNonzeroMagnitude
    }

    return clippingParent
  }
}

extension CALayer {
  /// Adds the given animation to this layer, timed with the given timing configuration
  @nonobjc
  func add(_ animation: CAPropertyAnimation, timedWith context: LayerAnimationContext) {
    add(animation.timed(with: context, for: self), forKey: animation.keyPath)
  }
}
