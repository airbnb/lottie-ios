// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Adds animations for the given `Ellipse` to this `CALayer`
  func addAnimations(
    for ellipse: Ellipse,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: ellipse.size.keyframes,
      value: { sizeKeyframe in
        let ellipseSize = sizeKeyframe.sizeValue

        // TODO: Is there a reasonable way to handle multiple sets
        // of keyframes that apply to the same value (`path`, in this case)?
        //  - This seems somewhat unlikely -- if it turns out to be necessary,
        //    this will probably have to be reworked to use more sublayers
        let center = ellipse.position.keyframes.first!.value.pointValue
        if ellipse.position.keyframes.count > 1 {
          fatalError("Ellipse position keyframes are unsupported")
        }

        var half = ellipseSize * 0.5
        if ellipse.direction == .counterClockwise {
          half.width = half.width * -1
        }

        let q1 = CGPoint(x: center.x, y: center.y - half.height)
        let q2 = CGPoint(x: center.x + half.width, y: center.y)
        let q3 = CGPoint(x: center.x, y: center.y + half.height)
        let q4 = CGPoint(x: center.x - half.width, y: center.y)

        let controlPoint = half * EllipseNode.ControlPointConstant

        var path = BezierPath(startPoint: CurveVertex(
          point: q1,
          inTangentRelative: CGPoint(x: -controlPoint.width, y: 0),
          outTangentRelative: CGPoint(x: controlPoint.width, y: 0)))

        path.addVertex(CurveVertex(
          point: q2,
          inTangentRelative: CGPoint(x: 0, y: -controlPoint.height),
          outTangentRelative: CGPoint(x: 0, y: controlPoint.height)))

        path.addVertex(CurveVertex(
          point: q3,
          inTangentRelative: CGPoint(x: controlPoint.width, y: 0),
          outTangentRelative: CGPoint(x: -controlPoint.width, y: 0)))

        path.addVertex(CurveVertex(
          point: q4,
          inTangentRelative: CGPoint(x: 0, y: controlPoint.height),
          outTangentRelative: CGPoint(x: 0, y: -controlPoint.height)))

        path.addVertex(CurveVertex(
          point: q1,
          inTangentRelative: CGPoint(x: -controlPoint.width, y: 0),
          outTangentRelative: CGPoint(x: controlPoint.width, y: 0)))

        path.close()
        return path.cgPath()
      },
      context: context)
  }
}
