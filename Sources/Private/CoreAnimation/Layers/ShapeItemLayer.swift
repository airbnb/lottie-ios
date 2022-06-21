// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeItemLayer

/// A CALayer type that renders an array of `[ShapeItem]`s,
/// from a `Group` in a `ShapeLayerModel`.
final class ShapeItemLayer: BaseAnimationLayer {

  // MARK: Lifecycle

  /// Initializes a `ShapeItemLayer` that renders a `Group` from a `ShapeLayerModel`
  /// - Parameters:
  ///   - shape: The `ShapeItem` in this group that renders a `GGPath`
  ///   - otherItems: Other items in this group that affect the appearance of the shape
  init(shape: Item, otherItems: [Item], context: LayerContext) throws {
    self.shape = shape
    self.otherItems = otherItems

    try context.compatibilityAssert(
      shape.item.drawsCGPath,
      "`ShapeItemLayer` must contain exactly one `ShapeItem` that draws a `GPPath`")

    try context.compatibilityAssert(
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

  override func setupAnimations(context: LayerAnimationContext) throws {
    try super.setupAnimations(context: context)

    guard let sublayerConfiguration = sublayerConfiguration else { return }

    switch sublayerConfiguration.fill {
    case .solidFill(let shapeLayer):
      try setupSolidFillAnimations(shapeLayer: shapeLayer, context: context)

    case .gradientFill(let gradientLayers):
      try setupGradientFillAnimations(
        gradientLayer: gradientLayers.gradientLayer,
        maskLayer: gradientLayers.maskLayer,
        context: context)
    }

    if let gradientStrokeConfiguration = sublayerConfiguration.gradientStroke {
      try setupGradientStrokeAnimations(
        gradientLayer: gradientStrokeConfiguration.gradientLayer,
        maskLayer: gradientStrokeConfiguration.maskLayer,
        context: context)
    }
  }

  // MARK: Private

  private struct GradientLayers {
    /// The `CALayer` that renders the actual gradient
    let gradientLayer: GradientRenderLayer
    /// The `CAShapeLayer` that clips the gradient layer to the expected shape
    let maskLayer: CAShapeLayer
  }

  /// The configuration of this layer's `fill` sublayers
  private enum FillLayerConfiguration {
    /// This layer displays a single `CAShapeLayer`
    case solidFill(CAShapeLayer)

    /// This layer displays a `GradientRenderLayer` masked by a `CAShapeLayer`.
    case gradientFill(GradientLayers)
  }

  /// The `ShapeItem` in this group that renders a `GGPath`
  private let shape: Item

  /// Other items in this group that affect the appearance of the shape
  private let otherItems: [Item]

  /// The current configuration of this layer's sublayer(s)
  private var sublayerConfiguration: (fill: FillLayerConfiguration, gradientStroke: GradientLayers?)?

  private func setupLayerHierarchy() {
    // We have to build a different layer hierarchy depending on if
    // we're rendering a gradient (a `CAGradientLayer` masked by a `CAShapeLayer`)
    // or a solid shape (a simple `CAShapeLayer`).
    let fillLayerConfiguration: FillLayerConfiguration
    if otherItems.contains(where: { $0.item is GradientFill }) {
      fillLayerConfiguration = setupGradientFillLayerHierarchy()
    } else {
      fillLayerConfiguration = setupSolidFillLayerHierarchy()
    }

    let gradientStrokeConfiguration: GradientLayers?
    if otherItems.contains(where: { $0.item is GradientStroke }) {
      gradientStrokeConfiguration = setupGradientStrokeLayerHierarchy()
    } else {
      gradientStrokeConfiguration = nil
    }

    sublayerConfiguration = (fillLayerConfiguration, gradientStrokeConfiguration)
  }

  private func setupSolidFillLayerHierarchy() -> FillLayerConfiguration {
    let shapeLayer = CAShapeLayer()
    addSublayer(shapeLayer)

    // `CAShapeLayer.fillColor` defaults to black, so we have to
    // nil out the background color if there isn't an expected fill color
    if !otherItems.contains(where: { $0.item is Fill }) {
      shapeLayer.fillColor = nil
    }

    return .solidFill(shapeLayer)
  }

  private func setupGradientFillLayerHierarchy() -> FillLayerConfiguration {
    let pathMask = CAShapeLayer()
    pathMask.fillColor = .rgb(0, 0, 0)
    mask = pathMask

    let gradientLayer = GradientRenderLayer()
    addSublayer(gradientLayer)

    return .gradientFill(.init(gradientLayer: gradientLayer, maskLayer: pathMask))
  }

  private func setupGradientStrokeLayerHierarchy() -> GradientLayers {
    let container = BaseAnimationLayer()

    let pathMask = CAShapeLayer()
    pathMask.fillColor = nil
    pathMask.strokeColor = .rgb(0, 0, 0)
    container.mask = pathMask

    let gradientLayer = GradientRenderLayer()
    container.addSublayer(gradientLayer)
    addSublayer(container)

    return .init(gradientLayer: gradientLayer, maskLayer: pathMask)
  }

  private func setupSolidFillAnimations(
    shapeLayer: CAShapeLayer,
    context: LayerAnimationContext)
    throws
  {
    var trimPathMultiplier: PathMultiplier? = nil
    if let (trim, context) = otherItems.first(Trim.self, context: context) {
      trimPathMultiplier = try shapeLayer.addAnimations(for: trim, context: context)
    }

    try shapeLayer.addAnimations(for: shape.item, context: context.for(shape), pathMultiplier: trimPathMultiplier ?? 1)

    if let (fill, context) = otherItems.first(Fill.self, context: context) {
      try shapeLayer.addAnimations(for: fill, context: context)
    }

    if let (stroke, context) = otherItems.first(Stroke.self, context: context) {
      try shapeLayer.addStrokeAnimations(for: stroke, context: context)
    }
  }

  private func setupGradientFillAnimations(
    gradientLayer: GradientRenderLayer,
    maskLayer: CAShapeLayer,
    context: LayerAnimationContext)
    throws
  {
    try maskLayer.addAnimations(for: shape.item, context: context.for(shape), pathMultiplier: 1)

    if let (gradientFill, context) = otherItems.first(GradientFill.self, context: context) {
      try gradientLayer.addGradientAnimations(for: gradientFill, context: context)
    }
  }

  private func setupGradientStrokeAnimations(
    gradientLayer: GradientRenderLayer,
    maskLayer: CAShapeLayer,
    context: LayerAnimationContext)
    throws
  {
    var trimPathMultiplier: PathMultiplier? = nil
    if let (trim, context) = otherItems.first(Trim.self, context: context) {
      trimPathMultiplier = try maskLayer.addAnimations(for: trim, context: context)
    }

    try maskLayer.addAnimations(for: shape.item, context: context.for(shape), pathMultiplier: trimPathMultiplier ?? 1)

    if let (gradientStroke, context) = otherItems.first(GradientStroke.self, context: context) {
      try gradientLayer.addGradientAnimations(for: gradientStroke, context: context)
      try maskLayer.addStrokeAnimations(for: gradientStroke, context: context)
    }
  }

}

// MARK: - [ShapeItem] helpers

extension Array where Element == ShapeItemLayer.Item {
  /// The first `ShapeItem` in this array of the given type
  func first<ItemType: ShapeItem>(
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
  func `for`(_ item: ShapeItemLayer.Item) -> LayerAnimationContext {
    var context = self

    if let group = item.parentGroup {
      context.currentKeypath.keys.append(group.name)
    }

    context.currentKeypath.keys.append(item.item.name)
    return context
  }
}
