// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Ellipse` to this `CALayer`
  @nonobjc
  func addAnimations(
    for ellipse: Ellipse,
    context: LayerAnimationContext)
    throws
  {
    try addAnimation(
      for: .path,
      keyframes: ellipse.size.keyframes,
      value: { sizeKeyframe in
        BezierPath.ellipse(
          size: sizeKeyframe.sizeValue,
          center: try ellipse.position.exactlyOneKeyframe(context: context, description: "ellipse position").value.pointValue,
          direction: ellipse.direction)
          .cgPath()
      },
      context: context)
  }
}
