// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeItemLayer

/// A CALayer type that renders an array of `[ShapeItem]`s,
/// from a `Group` in a `ShapeLayerModel`.
final class ShapeItemLayer: CALayer {

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

    LottieLogger.shared.assert(
      shape.drawsCGPath,
      "`ShapeItemLayer` must contain exactly one `ShapeItem` that draws a `GPPath`")

    LottieLogger.shared.assert(
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

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for managedLayer in managedLayers {
      managedLayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  /// The `ShapeItem` in this group that renders a `GGPath`
  private let shape: ShapeItem

  /// Other items in this group that affect the appearance of the shape
  private let otherItems: [ShapeItem]

  /// Sublayers managed by this layer
  private var managedLayers: [CALayer] {
    (sublayers ?? []) + [mask].compactMap { $0 }
  }

}

// MARK: AnimationLayer

extension ShapeItemLayer: AnimationLayer {

  // MARK: Internal

  func setupAnimations(context: LayerAnimationContext) {
    // We have to build a different layer hierarchy depending on if
    // we're rendering a gradient (a `CAGradientLayer` masked by a `CAShapeLayer`)
    // or a solid shape (a simple `CAShapeLayer`).
    if let gradientFill = otherItems.first(GradientFill.self) {
      setupAnimations(for: gradientFill, context: context)
    } else {
      setupAnimations(for: otherItems.first(Fill.self), context: context)
    }

    if let shapeTransform = otherItems.first(ShapeTransform.self) {
      addTransformAnimations(for: shapeTransform, context: context)
      addOpacityAnimation(from: shapeTransform, context: context)
    }
  }

  // MARK: Private

  /// Sets up the layer hierarchy and animations for a `CAShapeLayer`
  /// filled by a solid color specified by the `Fill` item.
  private func setupAnimations(
    for fill: Fill?,
    context: LayerAnimationContext)
  {
    let shapeLayer = CAShapeLayer()
    addSublayer(shapeLayer)
    shapeLayer.fillBoundsOfSuperlayer()

    shapeLayer.addAnimations(for: shape, context: context)

    if let fill = fill {
      shapeLayer.addAnimations(for: fill, context: context)
    } else {
      shapeLayer.fillColor = nil
    }

    if let stroke = otherItems.first(Stroke.self) {
      shapeLayer.addAnimations(for: stroke, context: context)
    }

    if let trim = otherItems.first(Trim.self) {
      shapeLayer.addAnimations(for: trim, context: context)
    }
  }

  /// Sets up the layer hierarchy and animations for a `CAGradientLayer`
  /// displaying the given `GradientFill`, masked by a `CAShapeLayer`.
  private func setupAnimations(
    for gradientFill: GradientFill,
    context: LayerAnimationContext)
  {
    let pathMask = CAShapeLayer()
    pathMask.fillColor = .rgb(0, 0, 0)
    mask = pathMask
    pathMask.fillBoundsOfSuperlayer()
    pathMask.addAnimations(for: shape, context: context)

    let gradientLayer = GradientRenderLayer()
    addSublayer(gradientLayer)
    gradientLayer.layout(superlayerBounds: bounds)

    gradientLayer.addAnimations(for: gradientFill, context: context)
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
