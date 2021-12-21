// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

/// The base type of `AnimationLayer` that can contain other `AnimationLayer`s
class BaseCompositionLayer: CALayer, AnimationLayer {

  // MARK: Lifecycle

  init(layerModel: LayerModel) {
    self.baseLayerModel = layerModel
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

    baseLayerModel = layer.baseLayerModel
    super.init(layer: layer)
  }

  // MARK: Internal

  // Components of this layer's `Transform` that should not be animated
  //  - By default, all components are animated
  //  - Can be overridden by subclasses
  var transformComponentsToAnimate: [TransformComponent] {
    .all
  }

  /// Sets up the base `LayerModel` animations for this layer,
  /// and all child `AnimationLayer`s.
  ///  - Can be overridden by subclasses, which much call `super`.
  func setupAnimations(context: LayerAnimationContext) {
    addAnimations(
      for: baseLayerModel.transform,
      components: transformComponentsToAnimate,
      context: context)

    for childAnimationLayer in childAnimationLayers {
      childAnimationLayer.setupAnimations(context: context)
    }
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let baseLayerModel: LayerModel

  // Debug helper that sets a specific border color for each type of layer
  //  - Can be called from `layoutSublayers()` when debugging
  private func setupDebugColors() {
    borderWidth = 1

    switch baseLayerModel.type {
    case .precomp:
      borderColor = "#FF000".cgColor // red
    case .solid:
      borderColor = "#FFFF00".cgColor // yellow
    case .image:
      borderColor = "#FFA500".cgColor // orange
    case .null:
      borderColor = "#0000FF".cgColor // blue
    case .shape:
      borderColor = "#00FF00".cgColor // green
    case .text:
      borderColor = "#000000".cgColor // black
    }

    for childLayer in childAnimationLayers {
      if !(childLayer is BaseCompositionLayer) {
        childLayer.borderWidth = 1
        childLayer.borderColor = "#AAAAAA".cgColor // gray
      }
    }
  }

}

// MARK: - CALayer + animationLayers

extension CALayer {
  /// The sublayers of this layer that conform to `AnimationLayer`
  var childAnimationLayers: [AnimationLayer] {
    var animationLayers = [AnimationLayer]()

    for sublayer in (sublayers ?? []) {
      if let animationLayer = sublayer as? AnimationLayer {
        animationLayers.append(animationLayer)
      }
    }

    return animationLayers
  }
}
