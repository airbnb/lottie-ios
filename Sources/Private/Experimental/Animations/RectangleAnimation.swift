// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Adds animations for the given `Rectangle` to this `CALayer`
  func addAnimations(
    for rectangle: Rectangle,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: rectangle.size.keyframes,
      value: { sizeKeyframe in
        let size = sizeKeyframe.sizeValue * 0.5

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

        var bezierPath = BezierPath()
        let points: [CurveVertex]

        if cornerRadius <= 0 {
          /// No Corners
          points = [
            /// Lead In
            CurveVertex(
              point: CGPoint(x: size.width, y: -size.height),
              inTangentRelative: .zero,
              outTangentRelative: .zero)
              .translated(position),
            /// Corner 1
            CurveVertex(
              point: CGPoint(x: size.width, y: size.height),
              inTangentRelative: .zero,
              outTangentRelative: .zero)
              .translated(position),
            /// Corner 2
            CurveVertex(
              point: CGPoint(x: -size.width, y: size.height),
              inTangentRelative: .zero,
              outTangentRelative: .zero)
              .translated(position),
            /// Corner 3
            CurveVertex(
              point: CGPoint(x: -size.width, y: -size.height),
              inTangentRelative: .zero,
              outTangentRelative: .zero)
              .translated(position),
            /// Corner 4
            CurveVertex(
              point: CGPoint(x: size.width, y: -size.height),
              inTangentRelative: .zero,
              outTangentRelative: .zero)
              .translated(position),
          ]
        } else {
          let controlPoint = cornerRadius * EllipseNode.ControlPointConstant
          points = [
            /// Lead In
            CurveVertex(
              CGPoint(x: cornerRadius, y: 0),
              CGPoint(x: cornerRadius, y: 0),
              CGPoint(x: cornerRadius, y: 0))
              .translated(CGPoint(x: -cornerRadius, y: cornerRadius))
              .translated(CGPoint(x: size.width, y: -size.height))
              .translated(position),
            /// Corner 1
            CurveVertex(
              CGPoint(x: cornerRadius, y: 0), // In tangent
              CGPoint(x: cornerRadius, y: 0), // Point
              CGPoint(x: cornerRadius, y: controlPoint))
              .translated(CGPoint(x: -cornerRadius, y: -cornerRadius))
              .translated(CGPoint(x: size.width, y: size.height))
              .translated(position),
            CurveVertex(
              CGPoint(x: controlPoint, y: cornerRadius), // In tangent
              CGPoint(x: 0, y: cornerRadius), // Point
              CGPoint(x: 0, y: cornerRadius)) // Out Tangent
              .translated(CGPoint(x: -cornerRadius, y: -cornerRadius))
              .translated(CGPoint(x: size.width, y: size.height))
              .translated(position),
            /// Corner 2
            CurveVertex(
              CGPoint(x: 0, y: cornerRadius), // In tangent
              CGPoint(x: 0, y: cornerRadius), // Point
              CGPoint(x: -controlPoint, y: cornerRadius))// Out tangent
              .translated(CGPoint(x: cornerRadius, y: -cornerRadius))
              .translated(CGPoint(x: -size.width, y: size.height))
              .translated(position),
            CurveVertex(
              CGPoint(x: -cornerRadius, y: controlPoint), // In tangent
              CGPoint(x: -cornerRadius, y: 0), // Point
              CGPoint(x: -cornerRadius, y: 0)) // Out tangent
              .translated(CGPoint(x: cornerRadius, y: -cornerRadius))
              .translated(CGPoint(x: -size.width, y: size.height))
              .translated(position),
            /// Corner 3
            CurveVertex(
              CGPoint(x: -cornerRadius, y: 0), // In tangent
              CGPoint(x: -cornerRadius, y: 0), // Point
              CGPoint(x: -cornerRadius, y: -controlPoint)) // Out tangent
              .translated(CGPoint(x: cornerRadius, y: cornerRadius))
              .translated(CGPoint(x: -size.width, y: -size.height))
              .translated(position),
            CurveVertex(
              CGPoint(x: -controlPoint, y: -cornerRadius), // In tangent
              CGPoint(x: 0, y: -cornerRadius), // Point
              CGPoint(x: 0, y: -cornerRadius)) // Out tangent
              .translated(CGPoint(x: cornerRadius, y: cornerRadius))
              .translated(CGPoint(x: -size.width, y: -size.height))
              .translated(position),
            /// Corner 4
            CurveVertex(
              CGPoint(x: 0, y: -cornerRadius), // In tangent
              CGPoint(x: 0, y: -cornerRadius), // Point
              CGPoint(x: controlPoint, y: -cornerRadius)) // Out tangent
              .translated(CGPoint(x: -cornerRadius, y: cornerRadius))
              .translated(CGPoint(x: size.width, y: -size.height))
              .translated(position),
            CurveVertex(
              CGPoint(x: cornerRadius, y: -controlPoint), // In tangent
              CGPoint(x: cornerRadius, y: 0), // Point
              CGPoint(x: cornerRadius, y: 0)) // Out tangent
              .translated(CGPoint(x: -cornerRadius, y: cornerRadius))
              .translated(CGPoint(x: size.width, y: -size.height))
              .translated(position),
          ]
        }
        let reversed = rectangle.direction == .counterClockwise
        let pathPoints = reversed ? points.reversed() : points
        for point in pathPoints {
          bezierPath.addVertex(reversed ? point.reversed() : point)
        }
        bezierPath.close()

        return bezierPath.cgPath()
      },
      context: context)
  }
}
