// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

/// The `CALayer` type responsible for rendering `ImageLayerModel`s
final class ImageLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(
    imageLayer: ImageLayerModel,
    context: LayerContext)
  {
    self.imageLayer = imageLayer
    super.init(layerModel: imageLayer)
    setupSublayers(context: context)
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

    imageLayer = layer.imageLayer
    super.init(layer: layer)
  }

  // MARK: Private

  private let imageLayer: ImageLayerModel

  private func setupSublayers(context: LayerContext) {
    guard
      let imageAsset = context.assetLibrary?.imageAssets[imageLayer.referenceID],
      let image = context.imageProvider.imageForAsset(asset: imageAsset)
    else { return }

    contentsLayer.contents = image
  }

}
