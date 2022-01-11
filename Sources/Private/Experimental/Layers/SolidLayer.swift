// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - SolidLayer

final class SolidLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(_ solidLayer: SolidLayerModel) {
    self.solidLayer = solidLayer
    super.init(layerModel: solidLayer)
    setupContentLayer()
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

    solidLayer = typedLayer.solidLayer
    super.init(layer: typedLayer)
  }

  // MARK: Private

  private let solidLayer: SolidLayerModel

  private func setupContentLayer() {
    // Render the fill color in a child `CAShapeLayer`
    //  - Using a `CAShapeLayer` specifically, instead of a `CALayer` with a `backgroundColor`,
    //    allows the size of the fill shape to be different from `contentsLayer.size`.
    let shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = solidLayer.colorHex.cgColor
    shapeLayer.path = CGPath(rect: .init(x: 0, y: 0, width: solidLayer.width, height: solidLayer.height), transform: nil)
    addSublayer(shapeLayer)
  }

}
