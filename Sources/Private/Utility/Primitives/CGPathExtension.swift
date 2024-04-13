//
//  CGPathExtension.swift
//  Lottie
//
//  Created by Yuval Kalugny on 13/04/2024.
//

import CoreGraphics

func pathElementCallback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
  guard let info else { return }
  let container = Unmanaged<BezierPathContainer>.fromOpaque(info).takeUnretainedValue()
  var bezierPath = container.bezierPath

  switch element.pointee.type {
  case .moveToPoint:
    let point = element.pointee.points[0]
    bezierPath.moveToStartPoint(.init(.zero, point, .zero))
  case .addLineToPoint:
    let point = element.pointee.points[0]
    bezierPath.addLine(toPoint: point)
  case .addQuadCurveToPoint:
    let controlPoint = element.pointee.points[0]
    let endPoint = element.pointee.points[1]
    let controlPoint1 = CGPoint(
      x: (2.0 / 3.0) * (controlPoint.x - element.pointee.points[-1].x) + element.pointee.points[-1].x,
      y: (2.0 / 3.0) * (controlPoint.y - element.pointee.points[-1].y) + element.pointee.points[-1].y)
    let controlPoint2 = CGPoint(
      x: (2.0 / 3.0) * (controlPoint.x - endPoint.x) + endPoint.x,
      y: (2.0 / 3.0) * (controlPoint.y - endPoint.y) + endPoint.y)
    bezierPath.addCurve(toPoint: endPoint, outTangent: controlPoint1, inTangent: controlPoint2)
  case .addCurveToPoint:
    let controlPoint1 = element.pointee.points[0]
    let controlPoint2 = element.pointee.points[1]
    let endPoint = element.pointee.points[2]
    bezierPath.addCurve(toPoint: endPoint, outTangent: controlPoint1, inTangent: controlPoint2)
  case .closeSubpath:
    bezierPath.close()
  @unknown default:
    break
  }
}

// MARK: - BezierPathContainer

private class BezierPathContainer {

  // MARK: Lifecycle

  init(bezierPath: BezierPath) {
    self.bezierPath = bezierPath
  }

  // MARK: Internal

  var bezierPath: BezierPath

}

extension CGPath {

  var bezierPath: BezierPath {
    let path = BezierPath()
    let container = BezierPathContainer(bezierPath: path)

    // Pass the container to the C function properly managed
    let info = Unmanaged.passRetained(container).toOpaque()

    // Applying the callback function to each element in the CGPath
    apply(info: info, function: pathElementCallback)

    // Release the container after use to balance retain count
    Unmanaged.passUnretained(container).release()

    return path
  }
}
