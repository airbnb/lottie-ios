//
//  CGPathExtension.swift
//  Lottie
//
//  Created by Yuval Kalugny on 13/04/2024.
//

import CoreGraphics


extension CGPath {

  var bezierPath: BezierPath {
    var path = BezierPath()

    applyWithBlock { element in
      switch element.pointee.type {
      case .moveToPoint:
        let point = element.pointee.points[0]
        path.moveToStartPoint(.init(.zero, point, .zero))
      case .addLineToPoint:
        let point = element.pointee.points[0]
        path.addLine(toPoint: point)
      case .addQuadCurveToPoint:
        let controlPoint = element.pointee.points[0]
        let endPoint = element.pointee.points[1]
        let controlPoint1 = CGPoint(
                x: (2.0 / 3.0) * (controlPoint.x - element.pointee.points[-1].x) + element.pointee.points[-1].x,
                y: (2.0 / 3.0) * (controlPoint.y - element.pointee.points[-1].y) + element.pointee.points[-1].y)
        let controlPoint2 = CGPoint(
                x: (2.0 / 3.0) * (controlPoint.x - endPoint.x) + endPoint.x,
                y: (2.0 / 3.0) * (controlPoint.y - endPoint.y) + endPoint.y)
        path.addCurve(toPoint: endPoint, outTangent: controlPoint1, inTangent: controlPoint2)
      case .addCurveToPoint:
        let controlPoint1 = element.pointee.points[0]
        let controlPoint2 = element.pointee.points[1]
        let endPoint = element.pointee.points[2]
        path.addCurve(toPoint: endPoint, outTangent: controlPoint1, inTangent: controlPoint2)
      case .closeSubpath:
        path.close()
      @unknown default:
        break
      }
    }

    return path
  }
}
