// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerContext

/// Context available when constructing an `AnimationLayer`
struct LayerContext {
  let assetLibrary: AssetLibrary?
}

// MARK: - LayerModel + makeAnimationLayer

extension LayerModel {
  /// Constructs an `AnimationLayer` / `CALayer` that represents this `LayerModel`
  func makeAnimationLayer(context: LayerContext) -> AnimationLayer? {
    switch type {
    case .precomp:
      guard let preCompLayerModel = self as? PreCompLayerModel else {
        fatalError("Expected `precomp` layer to be a `PreCompLayerModel`")
      }

      return PreCompLayer(preCompLayer: preCompLayerModel, context: context)

    case .solid:
      guard let solidLayerModel = self as? SolidLayerModel else {
        fatalError("Expected `solid` layer to be a `SolidLayerModel`")
      }

      return SolidLayer(solidLayerModel)

    case .shape:
      guard let shapeLayerModel = self as? ShapeLayerModel else {
        fatalError("Expected `shape` layer to be a `ShapeLayerModel`")
      }

      return ShapeLayer(shapeLayer: shapeLayerModel)

    case .null:
      return NullLayer(layerModel: self)

    case .image:
      // currently unsupported
      return nil

    case .text:
      // currently unsupported
      return nil
    }
  }

}
