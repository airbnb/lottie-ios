// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Rectangle` to this `CALayer`
  @nonobjc
  func addAnimations(
    for rectangle: Rectangle,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: rectangle.size.keyframes,
      value: { sizeKeyframe in
        BezierPath.rectangle(
          position: rectangle.position.exactlyOneKeyframe.value.pointValue,
          size: sizeKeyframe.sizeValue,
          cornerRadius: rectangle.cornerRadius.exactlyOneKeyframe.value.cgFloatValue,
          direction: rectangle.direction)
          .cgPath()
      },
      context: context)
  }
}
