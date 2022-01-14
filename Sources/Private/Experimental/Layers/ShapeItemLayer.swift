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
  init(shape: Item, otherItems: [Item]) {
    self.shape = shape
    self.otherItems = otherItems

    LottieLogger.shared.assert(
      shape.item.drawsCGPath,
      "`ShapeItemLayer` must contain exactly one `ShapeItem` that draws a `GPPath`")

    LottieLogger.shared.assert(
      !otherItems.contains(where: { $0.item.drawsCGPath }),
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

  /// An item that can be displayed by this layer
  struct Item {
    /// A `ShapeItem` that should be rendered by this layer
    let item: ShapeItem

    /// The group that contains this `ShapeItem`, if applicable
    let parentGroup: Group?
  }

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
  private let shape: Item

  /// Other items in this group that affect the appearance of the shape
  private let otherItems: [Item]

  /// The current configuration of this layer's sublayer(s)
  private var sublayerConfiguration: SublayerConfiguration?

  private func setupLayerHierarchy() {
    // We have to build a different layer hierarchy depending on if
    // we're rendering a gradient (a `CAGradientLayer` masked by a `CAShapeLayer`)
    // or a solid shape (a simple `CAShapeLayer`).
    if otherItems.contains(where: { $0.item is GradientFill }) {
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
    if !otherItems.contains(where: { $0.item is Fill }) {
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

    if let (shapeTransform, context) = otherItems.first(ShapeTransform.self, context: context) {
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
    shapeLayer.addAnimations(for: shape.item, context: context.for(shape))

    if let (fill, context) = otherItems.first(Fill.self, context: context) {
      shapeLayer.addAnimations(for: fill, context: context)
    }

    if let (stroke, context) = otherItems.first(Stroke.self, context: context) {
      shapeLayer.addAnimations(for: stroke, context: context)
    }

    if let (trim, context) = otherItems.first(Trim.self, context: context) {
      shapeLayer.addAnimations(for: trim, context: context)
    }
  }

  private func setupGradientFillAnimations(
    gradientLayer: GradientRenderLayer,
    maskLayer: CAShapeLayer,
    context: LayerAnimationContext)
  {
    maskLayer.addAnimations(for: shape.item, context: context.for(shape))

    if let (gradientFill, context) = otherItems.first(GradientFill.self, context: context) {
      gradientLayer.addAnimations(for: gradientFill, context: context)
    }
  }

}

// MARK: - [ShapeItem] helpers

extension Array where Element == ShapeItemLayer.Item {
  /// The first `ShapeItem` in this array of the given type
  fileprivate func first<ItemType: ShapeItem>(
    _: ItemType.Type, context: LayerAnimationContext)
    -> (item: ItemType, context: LayerAnimationContext)?
  {
    for item in self {
      if let match = item.item as? ItemType {
        return (match, context.for(item))
      }
    }

    return nil
  }
}

extension LayerAnimationContext {
  /// An updated `LayerAnimationContext` with the`AnimationKeypath`
  /// that refers to this specific `ShapeItem`.
  fileprivate func `for`(_ item: ShapeItemLayer.Item) -> LayerAnimationContext {
    var context = self

    if let group = item.parentGroup {
      context.currentKeypath.keys.append(group.name)
    }

    context.currentKeypath.keys.append(item.item.name)
    return context
  }
}
