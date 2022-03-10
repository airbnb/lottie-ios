// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Adds an animation for the given `inTime` and `outTime` to this `CALayer`
  @nonobjc
  func addVisibilityAnimation(
    inFrame: AnimationFrameTime,
    outFrame: AnimationFrameTime,
    context: LayerAnimationContext)
  {
    let animation = CAKeyframeAnimation(keyPath: #keyPath(isHidden))
    animation.calculationMode = .discrete

    animation.values = [
      true, // hidden, before `inFrame`
      false, // visible
      true, // hidden, after `outFrame`
    ]

    // From the documentation of `keyTimes`:
    //  - If the calculationMode is set to discrete, the first value in the array
    //    must be 0.0 and the last value must be 1.0. The array should have one more
    //    entry than appears in the values array. For example, if there are two values,
    //    there should be three key times.
    animation.keyTimes = [
      NSNumber(value: 0.0),
      NSNumber(value: max(Double(context.progressTime(for: inFrame)), 0)),
      NSNumber(value: min(Double(context.progressTime(for: outFrame)), 1)),
      NSNumber(value: 1.0),
    ]

    add(animation, timedWith: context)
  }
}
