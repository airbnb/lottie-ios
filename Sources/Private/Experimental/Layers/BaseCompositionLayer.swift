// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - BaseCompositionLayer

/// The base type of `AnimationLayer` that can contain other `AnimationLayer`s
class BaseCompositionLayer: CALayer, AnimationLayer {

  // MARK: Lifecycle

  init(layerModel: LayerModel) {
    baseLayerModel = layerModel
    super.init()

    setupSublayers()
    name = layerModel.name
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

    baseLayerModel = layer.baseLayerModel
    super.init(layer: layer)
  }

  // MARK: Internal

  /// The layer that the `LayerModel.transform` is applied to
  ///  - Child `LayerModel`s should always be added to this layer,
  ///    so they inherit the transform of the parent layer.
  let transformLayer: CALayer = {
    let layer = CALayer()
    layer.name = "transform"
    return layer
  }()

  /// The layer that should render visible elements displayed by this layer's `LayerModel`
  ///  - This layer applies `LayerModel.transform.opacity`, which applies to this specific
  ///    `LayerModel`'s content and not the content of any child `LayerModel`s.
  let contentsLayer: CALayer = {
    let layer = CALayer()
    layer.name = "contents"
    return layer
  }()

  override func addSublayer(_: CALayer) {
    fatalError("""
    Sublayers should not be added directly to `BaseCompositionLayer`.
    Instead, add sublayers to either `transformLayer` or `contentsLayer`.
    """)
  }

  /// Sets up the base `LayerModel` animations for this layer,
  /// and all child `AnimationLayer`s.
  ///  - Can be overridden by subclasses, which much call `super`.
  func setupAnimations(context: LayerAnimationContext) {
    transformLayer.addTransformAnimations(for: baseLayerModel.transform, context: context)

    // Add the opacity and visibility animations to _only_ the `contentsLayer`
    //  - These animations should affect the content rendered directly by this layer,
    //    but _not_ any child `LayerModel`s.
    contentsLayer.addOpacityAnimation(from: baseLayerModel.transform, context: context)

    contentsLayer.addVisibilityAnimation(
      inFrame: CGFloat(baseLayerModel.inFrame),
      outFrame: CGFloat(baseLayerModel.outFrame),
      context: context)

    for childAnimationLayer in managedSublayers {
      (childAnimationLayer as? AnimationLayer)?.setupAnimations(context: context)
    }
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in managedSublayers {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let baseLayerModel: LayerModel

  /// All of the sublayers managed by this `BaseCompositionLayer`
  private var managedSublayers: [CALayer] {
    (sublayers ?? [])
      + (transformLayer.sublayers ?? [])
      + (contentsLayer.sublayers ?? [])
      + [contentsLayer.mask].compactMap { $0 }
  }

  private func setupSublayers() {
    super.addSublayer(transformLayer)
    transformLayer.addSublayer(contentsLayer)

    if let masks = baseLayerModel.masks {
      contentsLayer.mask = MaskCompositionLayer(masks: masks)
    }
  }

}
