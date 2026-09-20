// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - BaseCompositionLayer

/// The base type of `AnimationLayer` that can contain other `AnimationLayer`s
class BaseCompositionLayer: BaseAnimationLayer {

  // MARK: Lifecycle

  init(layerModel: LayerModel) {
    baseLayerModel = layerModel
    super.init()

    setupSublayers()
    compositingFilter = layerModel.blendMode.filterName
    name = layerModel.name
    contentsLayer.name = "\(layerModel.name) (Content)"
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

    baseLayerModel = typedLayer.baseLayerModel
    super.init(layer: typedLayer)
  }

  // MARK: Internal

  /// The layer that content / sublayers should be rendered in.
  /// This is the layer that transform animations are applied to.
  let contentsLayer = BaseAnimationLayer()

  /// Whether or not this layer render should render any visible content
  var renderLayerContents: Bool {
    true
  }

  /// Sets up the base `LayerModel` animations for this layer,
  /// and all child `AnimationLayer`s.
  ///  - Can be overridden by subclasses, which much call `super`.
  override func setupAnimations(context: LayerAnimationContext) throws {
    let layerContext = context.addingKeypathComponent(baseLayerModel.name)
    let childContext = renderLayerContents ? layerContext : context

    try setupLayerAnimations(context: layerContext)
    try setupChildAnimations(context: childContext)
  }

  func setupLayerAnimations(context: LayerAnimationContext) throws {
    if CALayer.isCreatingAnimationsInBackground {
      setupAnimationsOnBackgroundThread(context: context)
    } else {
      try setupAnimationsOnMainThread(context: context)
    }
  }

  func setupChildAnimations(context: LayerAnimationContext) throws {
    try super.setupAnimations(context: context)
  }

  override func addSublayer(_ layer: CALayer) {
    if layer === contentsLayer {
      super.addSublayer(contentsLayer)
    } else {
      contentsLayer.addSublayer(layer)
    }
  }

  // MARK: Private

  private let baseLayerModel: LayerModel

  // TODO: This is a throwing function. To preserve the semantics on this, we should aim to be able to throw an error from this branch as well
  private func setupAnimationsOnBackgroundThread(
    context: LayerAnimationContext
  ) {
    DispatchQueue.global().async {
      do {
        let animations = try self.animationsOnBackgroundThread(context: context)

        DispatchQueue.main.async {
          for (key, animation) in animations {
            self.contentsLayer.add(animation, forKey: key)
          }
          #if DEBUG
          TestHelpers.backgroundAnimationSetupComplete?()
          #endif
        }
      } catch { }
    }
  }

  private func animationsOnBackgroundThread(
    context: LayerAnimationContext
  ) throws -> AnimationsByKey {
    let transformContext = context.addingKeypathComponent("Transform")

    let positionAnimation = try contentsLayer.positionAnimations(
      from: baseLayerModel.transform,
      context: transformContext
    )

    let anchorPointAnimation = try contentsLayer.anchorPointAnimation(
      from: baseLayerModel.transform,
      context: transformContext
    )

    let scaleAnimation = try contentsLayer.scaleAnimations(
      from: baseLayerModel.transform,
      context: transformContext
    )

    let rotationAnimation = try contentsLayer.rotationAnimations(
      from: baseLayerModel.transform,
      context: transformContext
    )

    var appearanceAnimation = AnimationsByKey()
    if renderLayerContents {
      let opacityAnimation = try contentsLayer.opacityAnimation(
        for: baseLayerModel.transform,
        context: transformContext
      )

      let visibilityAnimation = try contentsLayer.visibilityAnimation(
        inFrame: CGFloat(baseLayerModel.inFrame),
        outFrame: CGFloat(baseLayerModel.outFrame),
        context: context
      )

      appearanceAnimation = Dictionary.merging(
        opacityAnimation,
        visibilityAnimation,
        uniquingKeysWith: { _, new in new }
      )
    }

    return Dictionary.merging(
      positionAnimation,
      anchorPointAnimation,
      scaleAnimation,
      rotationAnimation,
      appearanceAnimation,
      uniquingKeysWith: { _, new in new }
    )
  }

  private func setupAnimationsOnMainThread(
    context: LayerAnimationContext
  ) throws {
    let transformContext = context.addingKeypathComponent("Transform")
    try contentsLayer.addTransformAnimations(for: baseLayerModel.transform, context: transformContext)

    if renderLayerContents {
      try contentsLayer.addOpacityAnimation(for: baseLayerModel.transform, context: transformContext)

      try contentsLayer.addVisibilityAnimation(
        inFrame: CGFloat(baseLayerModel.inFrame),
        outFrame: CGFloat(baseLayerModel.outFrame),
        context: context
      )

      // There are two different drop shadow schemas, either using `DropShadowEffect` or `DropShadowStyle`.
      // If both happen to be present, prefer the `DropShadowEffect` (which is the drop shadow schema
      // supported on other platforms).
      let dropShadowEffect = baseLayerModel.effects.first(where: { $0 is DropShadowEffect }) as? DropShadowModel
      let dropShadowStyle = baseLayerModel.styles.first(where: { $0 is DropShadowStyle }) as? DropShadowModel
      if let dropShadowModel = dropShadowEffect ?? dropShadowStyle {
        try contentsLayer.addDropShadowAnimations(for: dropShadowModel, context: context)
      }

      // Set up mask animations with the layer's own context (parent timeline).
      // Mask keyframes are defined in the parent's global timeline, not the precomp's
      // local timeline, so the mask must not receive the time-remapped child context.
      if let maskLayer = contentsLayer.mask as? AnimationLayer {
        try maskLayer.setupAnimations(context: context)
      }
    }
  }

  private func setupSublayers() {
    addSublayer(contentsLayer)

    if
      renderLayerContents,
      let masks = baseLayerModel.masks?.filter({ $0.mode != .none }),
      !masks.isEmpty
    {
      contentsLayer.mask = MaskCompositionLayer(masks: masks)
    }
  }

}
