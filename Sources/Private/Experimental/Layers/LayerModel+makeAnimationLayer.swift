// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerContext

/// Context available when constructing an `AnimationLayer`
struct LayerContext {
  let assetLibrary: AssetLibrary?
  let imageProvider: AnimationImageProvider
}

// MARK: - LayerModel + makeAnimationLayer

extension LayerModel {
  /// Constructs an `AnimationLayer` / `CALayer` that represents this `LayerModel`
  func makeAnimationLayer(context: LayerContext) -> BaseCompositionLayer? {
    switch (type, self) {
    case (.precomp, let preCompLayerModel as PreCompLayerModel):
      return PreCompLayer(preCompLayer: preCompLayerModel, context: context)

    case (.solid, let solidLayerModel as SolidLayerModel):
      return SolidLayer(solidLayerModel)

    case (.shape, let shapeLayerModel as ShapeLayerModel):
      return ShapeLayer(shapeLayer: shapeLayerModel)

    case (.image, let imageLayerModel as ImageLayerModel):
      return ImageLayer(imageLayer: imageLayerModel, context: context)

    case (.null, _):
      return NullLayer(layerModel: self)

    default:
      // Other layer types (text) are currently unsupported
      return nil
    }
  }

}
