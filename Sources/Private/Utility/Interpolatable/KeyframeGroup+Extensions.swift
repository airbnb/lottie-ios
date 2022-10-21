//
//  KeyframeGroup+Extensions.swift
//  Lottie
//
//  Created by JT Bergman on 6/20/22.
//

import CoreGraphics
import Foundation

extension KeyframeGroup where T == LottieVector1D {
  /// Manually interpolates the keyframes so that they are defined linearly
  ///
  /// This method uses `UnitBezier` to perform the interpolation. It will create one keyframe
  /// for each frame of the animation. For instance, if it is given a keyframe at time 0 and a keyframe
  /// at time 10, it will create 10 interpolated keyframes. It is currently not optimized.
  func manuallyInterpolateKeyframes() -> ContiguousArray<Keyframe<T>> {
    guard keyframes.count > 1 else {
      return keyframes
    }

    var output = ContiguousArray<Keyframe<LottieVector1D>>()

    for idx in 1 ..< keyframes.count {
      let prev = keyframes[idx - 1]
      let curr = keyframes[idx]

      // The timing function is responsible for computing the expected progress
      let outTangent = prev.outTangent?.pointValue ?? .zero
      let inTangent = curr.inTangent?.pointValue ?? .init(x: 1, y: 1)
      let timingFunction = UnitBezier(controlPoint1: outTangent, controlPoint2: inTangent)

      // These values are used to compute new values in the adjusted keyframes
      let difference = curr.value.value - prev.value.value
      let startValue = prev.value.value
      let startTime = prev.time
      let duration = max(Int(curr.time - prev.time), 0)

      // Create one interpolated keyframe for each time in the duration
      for t in 0 ... duration {
        let progress = timingFunction.value(
          for: CGFloat(t) / CGFloat(duration),
          epsilon: 0.005)
        let value = startValue + Double(progress) * difference
        output.append(
          Keyframe<LottieVector1D>(
            value: LottieVector1D(value),
            time: startTime + CGFloat(t),
            isHold: false,
            inTangent: nil,
            outTangent: nil,
            spatialInTangent: nil,
            spatialOutTangent: nil))
      }
    }

    return output
  }
}
