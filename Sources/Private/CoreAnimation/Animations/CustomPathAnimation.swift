// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `BezierPath` keyframes to this `CALayer`
  @nonobjc
  func addAnimations(
    for customPath: KeyframeGroup<BezierPath>,
    context: LayerAnimationContext,
    pathMultiplier: PathMultiplier = 1,
    transformPath: (CGPath) -> CGPath = { $0 })
    throws
  {
    try addAnimation(
      for: .path,
      keyframes: customPath.keyframes,
      value: { pathKeyframe in
        transformPath(pathKeyframe.cgPath().duplicated(times: pathMultiplier))
      },
      context: context)
  }
}

extension CGPath {
  /// Duplicates this `CGPath` so that it is repeated the given number of times
  func duplicated(times: Int) -> CGPath {
    if times <= 1 {
      return self
    }

    let cgPath = CGMutablePath()

    for _ in 0..<times {
      cgPath.addPath(self)
    }

    return cgPath
  }
}
