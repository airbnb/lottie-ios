// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Ellipse` to this `CALayer`
  func addAnimations(
    for ellipse: Ellipse,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: ellipse.size.keyframes,
      value: { sizeKeyframe in
        let size = sizeKeyframe.sizeValue

        // TODO: Is there a reasonable way to handle multiple sets
        // of keyframes that apply to the same value (`path`, in this case)?
        //  - This seems somewhat unlikely -- if it turns out to be necessary,
        //    this will probably have to be reworked to use more sublayers
        let center = ellipse.position.keyframes.first!.value.pointValue
        if ellipse.position.keyframes.count > 1 {
          fatalError("Ellipse position keyframes are currently unsupported")
        }

        return BezierPath.ellipse(
          size: size,
          center: center,
          direction: ellipse.direction)
          .cgPath()
      },
      context: context)
  }
}
