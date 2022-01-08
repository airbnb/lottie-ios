// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Rectangle` to this `CALayer`
  func addAnimations(
    for rectangle: Rectangle,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: rectangle.size.keyframes,
      value: { sizeKeyframe in
        let size = sizeKeyframe.sizeValue

        // TODO: Is there a reasonable way to handle multiple sets
        // of keyframes that apply to the same value (`path`, in this case)?
        //  - This seems somewhat unlikely -- if it turns out to be necessary,
        //    this will probably have to be reworked to use more sublayers
        let position = rectangle.position.keyframes.first!.value.pointValue
        if rectangle.position.keyframes.count > 1 {
          fatalError("Rectangle position keyframes are currently unsupported")
        }

        let cornerRadius = min(min(rectangle.cornerRadius.keyframes.first!.value.cgFloatValue, size.width), size.height)
        if rectangle.cornerRadius.keyframes.count > 1 {
          fatalError("Rectangle corner cornerRadius keyframes are currently unsupported")
        }

        return BezierPath.rectangle(
          position: position,
          size: size,
          cornerRadius: cornerRadius,
          direction: rectangle.direction)
          .cgPath()
      },
      context: context)
  }
}
