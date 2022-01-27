// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `BezierPath` keyframes to this `CALayer`
  @nonobjc
  func addAnimations(
    for customPath: KeyframeGroup<BezierPath>,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: customPath.keyframes,
      value: { pathKeyframe in
        pathKeyframe.cgPath()
      },
      context: context)
  }
}
