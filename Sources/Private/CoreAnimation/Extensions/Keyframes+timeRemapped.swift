// Created by Cal Stephens on 1/8/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Foundation

extension Keyframes {

  static func timeRemapped<T: AnyInterpolatable>(_ keyframes: KeyframeGroup<T>, context: LayerAnimationContext) -> KeyframeGroup<T> {
    let minimumTime = context.animation.startFrame
    let maximumTime = context.animation.endFrame
    let animationLocalTimeRange = stride(from: minimumTime, to: maximumTime, by: 1.0)

    let interpolator = keyframes.interpolator

    let interpolatedRemappedKeyframes = animationLocalTimeRange.compactMap { globalTime -> Keyframe<T>? in
      let remappedLocalTime = context.complexTimeRemapping(globalTime)

      guard let valueAtRemappedTime = interpolator.value(frame: remappedLocalTime) as? T else {
        LottieLogger.shared.assertionFailure("""
          Failed to cast untyped keyframe values to expected type. This is an internal error.
          """)
        return nil
      }

      return Keyframe(
        value: valueAtRemappedTime,
        time: AnimationFrameTime(globalTime))
    }

    return KeyframeGroup(keyframes: ContiguousArray(interpolatedRemappedKeyframes))
  }

}
