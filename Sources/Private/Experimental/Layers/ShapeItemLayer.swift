// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeItemLayer

/// A CALayer type that renders an array of `[ShapeItem]`s,
/// from a `Group` in a `ShapeLayerModel`.
final class ShapeItemLayer: CAShapeLayer {

  // MARK: Lifecycle

  init(items: [ShapeItem]) {
    self.items = items
    super.init()

    path = items.path

    if let fill = items.first(Fill.self) {
      // TODO: Need to figure out how to handle keyframing
      fillColor = fill.color.keyframes.first!.value.cgColorValue
      opacity = Float(fill.opacity.keyframes.first!.value.value)
      fillRule = fill.fillRule.caFillRule
    }

    if let stroke = items.first(Stroke.self) {
      strokeColor = stroke.color.keyframes.first!.value.cgColorValue
        .copy(alpha: stroke.opacity.keyframes.first!.value.cgFloatValue)
      lineWidth = stroke.width.keyframes.first!.value.cgFloatValue
      lineJoin = stroke.lineJoin.caLineJoin
      lineCap = stroke.lineCap.caLineCap
      // TODO: Support `lineDashPhase` and `lineDashPattern`
    }

    if let shapeTransform = items.first(ShapeTransform.self) {
      // TODO: Need to figure out how to handle keyframing
      transform = CATransform3D.makeTransform(
        anchor: shapeTransform.anchor.keyframes.first!.value.pointValue,
        position: shapeTransform.position.keyframes.first!.value.pointValue,
        scale: shapeTransform.scale.keyframes.first!.value.sizeValue,
        rotation: shapeTransform.rotation.keyframes.first!.value.cgFloatValue,
        skew: shapeTransform.skew.keyframes.first!.value.cgFloatValue,
        skewAxis: shapeTransform.skewAxis.keyframes.first!.value.cgFloatValue)
    }
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private let items: [ShapeItem]

}

// MARK: AnimationLayer

extension ShapeItemLayer: AnimationLayer {
  func animations(context _: LayerAnimationContext) -> [CAPropertyAnimation] {
    [] // TODO: implement
  }
}

// MARK: - [ShapeItem] helpers

extension Array where Element == ShapeItem {
  /// The CGPath formed by combining all of the path-providing `ShapeItem`s in this set of shape items
  var path: CGPath {
    let path = CGMutablePath()

    for item in self {
      if let pathConstructing = item as? PathConstructing {
        path.addPath(pathConstructing.makePath())
      }
    }

    return path
  }

  /// The first `ShapeItem` in this array of the given type
  func first<Item: ShapeItem>(_: Item.Type) -> Item? {
    for item in self {
      if let match = item as? Item {
        return match
      }
    }

    return nil
  }
}

// MARK: - PathConstructing

protocol PathConstructing {
  func makePath() -> CGPath
}

// MARK: - Ellipse + PathConstructing

extension Ellipse: PathConstructing {
  func makePath() -> CGPath {
    // TODO: Will need to figure out how keyframing works
    let ellipseSize = size.keyframes.first!.value.sizeValue
    let center = position.keyframes.first!.value.pointValue

    var half = ellipseSize * 0.5
    if direction == .counterClockwise {
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
  }
}
