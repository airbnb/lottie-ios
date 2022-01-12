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

    setupLayerHierarchy()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let typedLayer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    shape = typedLayer.shape
    otherItems = typedLayer.otherItems
    super.init(layer: typedLayer)
  }

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayerConfiguration?.layers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  /// The configuration of this layer's sublayers
  private enum SublayerConfiguration {
    /// This layer displays a single `CAShapeLayer`
    case solidFill(shapeLayer: CAShapeLayer)

    /// This layer displays a `GradientRenderLayer` masked by a `CAShapeLayer`.
    case gradientFill(gradientLayer: GradientRenderLayer, maskLayer: CAShapeLayer)

    var layers: [CALayer] {
      switch self {
      case .solidFill(let shapeLayer):
        return [shapeLayer]
      case .gradientFill(let gradientLayer, let maskLayer):
        return [gradientLayer, maskLayer]
      }
    }
  }

  /// The `ShapeItem` in this group that renders a `GGPath`
  private let shape: ShapeItem

  /// Other items in this group that affect the appearance of the shape
  private let otherItems: [ShapeItem]

  /// The current configuration of this layer's sublayer(s)
  private var sublayerConfiguration: SublayerConfiguration?

  private func setupLayerHierarchy() {
    // We have to build a different layer hierarchy depending on if
    // we're rendering a gradient (a `CAGradientLayer` masked by a `CAShapeLayer`)
    // or a solid shape (a simple `CAShapeLayer`).
    if otherItems.first(GradientFill.self) != nil {
      setupGradientFillLayerHierarchy()
    } else {
      setupSolidFillLayerHierarchy()
    }
  }

  private func setupSolidFillLayerHierarchy() {
    let shapeLayer = CAShapeLayer()
    addSublayer(shapeLayer)

    // `CAShapeLayer.fillColor` defaults to black, so we have to
    // nil out the background color if there isn't an expected fill color
    if otherItems.first(Fill.self) == nil {
      shapeLayer.fillColor = nil
    }

    sublayerConfiguration = .solidFill(shapeLayer: shapeLayer)
  }

  private func setupGradientFillLayerHierarchy() {
    let pathMask = CAShapeLayer()
    pathMask.fillColor = .rgb(0, 0, 0)
    mask = pathMask

    let gradientLayer = GradientRenderLayer()
    addSublayer(gradientLayer)

    sublayerConfiguration = .gradientFill(gradientLayer: gradientLayer, maskLayer: pathMask)
  }

}

// MARK: AnimationLayer

extension ShapeItemLayer: AnimationLayer {

  // MARK: Internal

  func setupAnimations(context: LayerAnimationContext) {
    guard let sublayerConfiguration = sublayerConfiguration else { return }

    if let shapeTransform = otherItems.first(ShapeTransform.self) {
      addTransformAnimations(for: shapeTransform, context: context)
      addOpacityAnimation(from: shapeTransform, context: context)
    }

    switch sublayerConfiguration {
    case .solidFill(let shapeLayer):
      setupSolidFillAnimations(shapeLayer: shapeLayer, context: context)

    case .gradientFill(let gradientLayer, let maskLayer):
      setupGradientFillAnimations(gradientLayer: gradientLayer, maskLayer: maskLayer, context: context)
    }
  }

  // MARK: Private

  private func setupSolidFillAnimations(
    shapeLayer: CAShapeLayer,
    context: LayerAnimationContext)
  {
    shapeLayer.addAnimations(for: shape, context: context)

    if let fill = otherItems.first(Fill.self) {
      shapeLayer.addAnimations(for: fill, context: context)
    }

    if let stroke = otherItems.first(Stroke.self) {
      shapeLayer.addAnimations(for: stroke, context: context)
    }

    if let trim = otherItems.first(Trim.self) {
      shapeLayer.addAnimations(for: trim, context: context)
    }
  }

  private func setupGradientFillAnimations(
    gradientLayer: GradientRenderLayer,
    maskLayer: CAShapeLayer,
    context: LayerAnimationContext)
  {
    maskLayer.addAnimations(for: shape, context: context)

    if let gradientFill = otherItems.first(GradientFill.self) {
      gradientLayer.addAnimations(for: gradientFill, context: context)
    }
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
