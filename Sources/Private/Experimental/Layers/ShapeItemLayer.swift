// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeItemLayer

/// A CALayer type that renders an array of `[ShapeItem]`s,
/// from a `Group` in a `ShapeLayerModel`.
final class ShapeItemLayer: CAShapeLayer {

  // MARK: Lifecycle

  /// Initializes a `ShapeItemLayer` that renders a `Group` from a `ShapeLayerModel`
  /// - Parameters:
  ///   - shape: The `ShapeItem` in this group that renders a `GGPath`
  ///   - otherItems: Other items in this group that affect the appearance of the shape
  init(
    shape: ShapeItem,
    otherItems: [ShapeItem])
  {
    self.shape = shape
    self.otherItems = otherItems

    assert(
      shape.drawsCGPath,
      "`ShapeItemLayer` must contain exactly one `ShapeItem` that draws a `GPPath`")

    assert(
      !otherItems.contains(where: { $0.drawsCGPath }),
      "`ShapeItemLayer` must contain exactly one `ShapeItem` that draws a `GPPath`")

    super.init()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let layer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    shape = layer.shape
    otherItems = layer.otherItems
    super.init(layer: layer)
  }

  // MARK: Private

  /// The `ShapeItem` in this group that renders a `GGPath`
  private let shape: ShapeItem

  /// Other items in this group that affect the appearance of the shape
  private let otherItems: [ShapeItem]

}

// MARK: AnimationLayer

extension ShapeItemLayer: AnimationLayer {

  // MARK: Internal

  func setupAnimations(context: LayerAnimationContext) {
    setupPathAnimation(context: context)

    if let shapeTransform = otherItems.first(ShapeTransform.self) {
      addAnimations(for: shapeTransform, context: context)
    }

    if let fill = otherItems.first(Fill.self) {
      addAnimations(for: fill, context: context)
    } else {
      fillColor = nil
    }

    if let stroke = otherItems.first(Stroke.self) {
      addAnimations(for: stroke, context: context)
    }

    if let trim = otherItems.first(Trim.self) {
      addAnimations(for: trim, context: context)
    }

    // TODO: animate more properties
  }

  // MARK: Private

  private func setupPathAnimation(context: LayerAnimationContext) {
    switch shape {
    case let customShape as Shape:
      addAnimations(for: customShape, context: context)

    case let ellipse as Ellipse:
      addAnimations(for: ellipse, context: context)

    case let rectangle as Rectangle:
      addAnimations(for: rectangle, context: context)

    default:
      // Other path types are currently unsupported
      return
    }
  }

  private func addAnimations(for fill: Fill, context: LayerAnimationContext) {
    fillRule = fill.fillRule.caFillRule

    addAnimation(
      for: .fillColor,
      keyframes: fill.color.keyframes,
      value: \.cgColorValue,
      context: context)

    // TODO: What's the difference between `fill.opacity` and `transform.opacity`?
    // We probably can't animate both simultaneously
    // opacity = Float(fill.opacity.keyframes.first!.value.value)
  }

  private func addAnimations(for stroke: Stroke, context: LayerAnimationContext) {
    lineJoin = stroke.lineJoin.caLineJoin
    lineCap = stroke.lineCap.caLineCap
    miterLimit = CGFloat(stroke.miterLimit)

    addAnimation(
      for: .strokeColor,
      keyframes: stroke.color.keyframes,
      value: \.cgColorValue,
      context: context)

    addAnimation(
      for: .lineWidth,
      keyframes: stroke.width.keyframes,
      value: \.cgFloatValue,
      context: context)

    // TODO: Support `lineDashPhase` and `lineDashPattern`
  }

  private func addAnimations(for trim: Trim, context: LayerAnimationContext) {
    addAnimation(
      for: .strokeStart,
      keyframes: trim.start.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / 100
      }, context: context)

    addAnimation(
      for: .strokeEnd,
      keyframes: trim.end.keyframes,
      value: { strokeEnd in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeEnd.cgFloatValue) / 100
      }, context: context)
  }
}

// MARK: - [ShapeItem] helpers

extension Array where Element == ShapeItem {
  /// The first `ShapeItem` in this array of the given type
  fileprivate func first<Item: ShapeItem>(_: Item.Type) -> Item? {
    for item in self {
      if let match = item as? Item {
        return match
      }
    }

    return nil
  }
}
