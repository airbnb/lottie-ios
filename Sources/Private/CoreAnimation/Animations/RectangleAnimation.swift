// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Rectangle` to this `CALayer`
  @nonobjc
  func addAnimations(
    for rectangle: Rectangle,
    context: LayerAnimationContext)
    throws
  {
    try addAnimation(
      for: .path,
      keyframes: rectangle.size.keyframes,
      value: { sizeKeyframe in
        BezierPath.rectangle(
          position: try rectangle.position
            .exactlyOneKeyframe(context: context, description: "rectangle position").value.pointValue,
          size: sizeKeyframe.sizeValue,
          cornerRadius: try rectangle.cornerRadius
            .exactlyOneKeyframe(context: context, description: "rectangle cornerRadius").value.cgFloatValue,
          direction: rectangle.direction)
          .cgPath()
      },
      context: context)
  }
}
