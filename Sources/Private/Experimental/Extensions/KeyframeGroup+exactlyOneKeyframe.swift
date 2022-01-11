// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

extension KeyframeGroup {
  /// Retrieves the first `Keyframe` from this group,
  /// and asserts that there are not any extra keyframes that would be ignored
  ///
  ///  - There are several places in Lottie animation definitions where multiple
  ///    sets of keyframe timings can be provided for properties that have to
  ///    be applied to a single `CALayer` property (for example, the definition for a
  ///    `Rectangle` technically lets you animate `size`, `position`, and `cornerRadius`
  ///    separately, but these all have to be combined into a single `CAKeyframeAnimation`
  ///    on the `CAShapeLayer.path` property.
  ///
  ///  - In those sorts of cases, we currently choose one one `KeyframeGroup` to provide the
  ///    timing information, and disallow simultaneous animations on the other properties.
  ///
  var exactlyOneKeyframe: Keyframe<T> {
    LottieLogger.shared.assert(
      keyframes.count == 1,
      """
      The experimental rendering engine does not support animating multiple keyframes
      for this value (due to limitations of Core Animation `CAKeyframeAnimation`s).
      """)

    return keyframes[0]
  }
}
