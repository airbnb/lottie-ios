// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

/// The `CALayer` type responsible for rendering `PreCompLayerModel`s
final class PreCompLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(
    preCompLayer: PreCompLayerModel,
    context: LayerContext)
  {
    self.preCompLayer = preCompLayer
    super.init(layerModel: preCompLayer)

    setupLayerHierarchy(
      for: context.assetLibrary?.precompAssets[preCompLayer.referenceID]?.layers ?? [],
      context: context)
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

    preCompLayer = typedLayer.preCompLayer
    super.init(layer: typedLayer)
  }

  // MARK: Private

  private let preCompLayer: PreCompLayerModel

}
