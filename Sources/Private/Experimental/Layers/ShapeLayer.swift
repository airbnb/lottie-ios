// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

/// The CALayer type responsible for rendering `ShapeLayerModel`s
final class ShapeLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(shapeLayer: ShapeLayerModel) {
    self.shapeLayer = shapeLayer
    super.init(layerModel: shapeLayer)

    for item in shapeLayer.items {
      // TODO: Can items other than `Group`s appear at the top level?
      // If so, how does that work?
      if let group = item as? Group {
        let sublayer = ShapeItemLayer(items: group.items)
        addSublayer(sublayer)
      }
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

    shapeLayer = layer.shapeLayer
    super.init(layer: layer)
  }

  // MARK: Private

  private let shapeLayer: ShapeLayerModel

}
