// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

/// The `CALayer` type responsible for rendering `PreCompLayerModel`s
final class PreCompLayer: CALayer {

  // MARK: Lifecycle

  init(
    preCompLayer: PreCompLayerModel,
    context: LayerContext)
  {
    self.preCompLayer = preCompLayer

    let preCompLayerModels = context.assetLibrary?.precompAssets[preCompLayer.referenceID]?.layers ?? []
    animationLayers = preCompLayerModels.compactMap { layerModel in
      (layerModel as? LayerConstructing)?.makeLayer(context: context)
    }

    super.init()

    for animationLayer in animationLayers {
      addSublayer(animationLayer)
    }
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

    preCompLayer = layer.preCompLayer
    animationLayers = []
    super.init(layer: layer)
  }

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let preCompLayer: PreCompLayerModel
  private let animationLayers: [AnimationLayer]

}

// MARK: AnimationLayer

extension PreCompLayer: AnimationLayer {
  func setupAnimations(context: LayerAnimationContext) {
    addBaseAnimations(for: preCompLayer, context: context)

    for animationLayer in animationLayers {
      animationLayer.setupAnimations(context: context)
    }
  }
}

// MARK: - ShapeLayerModel + LayerConstructing

extension PreCompLayerModel: LayerConstructing {
  func makeLayer(context: LayerContext) -> AnimationLayer {
    PreCompLayer(preCompLayer: self, context: context)
  }
}
