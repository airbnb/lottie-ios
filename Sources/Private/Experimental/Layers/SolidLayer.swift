// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - SolidLayer

final class SolidLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(_ solidLayer: SolidLayerModel) {
    self.solidLayer = solidLayer
    super.init(layerModel: solidLayer)

    backgroundColor = solidLayer.colorHex.cgColor
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

    solidLayer = layer.solidLayer
    super.init(layer: layer)
  }

  // MARK: Private

  private let solidLayer: SolidLayerModel

}
