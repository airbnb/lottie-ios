// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

final class ShapeLayer: CALayer {

  // MARK: Lifecycle

  init(shapeLayer: ShapeLayerModel) {
    self.shapeLayer = shapeLayer
    super.init()

    // TODO: On the model side, these fields are part of a `LayerModel` superclass.
    // We should put this somewhere where it doesn't have to be duplicated by
    // all layer types.
    transform = CATransform3D.makeTransform(
      anchor: shapeLayer.transform.anchorPoint.keyframes.first!.value.pointValue,
      position: shapeLayer.transform.position?.keyframes.first!.value.pointValue ?? .zero,
      scale: shapeLayer.transform.scale.keyframes.first!.value.sizeValue,
      rotation: shapeLayer.transform.rotation.keyframes.first!.value.cgFloatValue,
      skew: nil,
      skewAxis: nil)

    for item in shapeLayer.items {
      // TODO: Can items other than `Group`s appear at the top level?
      // If so, how does that work?
      if let group = item as? Group {
        let sublayer = ShapeItemLayer(items: group.items)

        // Set the sublayer's anchorPoint to (0, 0) so it has the
        // same coordinate space at this root layer
        //  - This allows us to set `layer.bounds = bounds`
        //    instead of `layer.frame = bounds`
        sublayer.anchorPoint = .zero

        // Sublayers should have the same bounds as this root layer
        sublayer.bounds = bounds

        addSublayer(sublayer)
      }
    }
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private let shapeLayer: ShapeLayerModel

}

// MARK: - ShapeLayerModel + LayerConstructing

extension ShapeLayerModel: LayerConstructing {
  func makeLayer() -> CALayer {
    ShapeLayer(shapeLayer: self)
  }
}
