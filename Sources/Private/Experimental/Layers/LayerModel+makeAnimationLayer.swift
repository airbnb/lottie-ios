// Created by Cal Stephens on 12/20/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerContext

/// Context available when constructing an `AnimationLayer`
struct LayerContext {
  let assetLibrary: AssetLibrary?
  let imageProvider: AnimationImageProvider
  let fontProvider: AnimationFontProvider
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

    case (.text, let textLayerModel as TextLayerModel):
      return TextLayer(textLayerModel: textLayerModel, context: context)

    case (.null, _):
      return TransformLayer(layerModel: self)

    default:
      LottieLogger.shared.assertionFailure("""
      Unexpected layer type combination ("\(type)" and "\(Swift.type(of: self))")
      """)

      return nil
    }
  }

}
