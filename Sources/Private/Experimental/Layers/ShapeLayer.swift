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

    // Each top-level `Group` item becomes its own `ShapeItemLayer` sublayer.
    // Other top-level `ShapeItem`s are applied to all sublayers.
    let groupItems = shapeLayer.items.compactMap { $0 as? Group }
    let otherItems = shapeLayer.items.filter { !($0 is Group) }

    // Groups are listed from front to back,
    // but `CALayer.sublayers` are listed from back to front.
    let groupsInZAxisOrder = groupItems.reversed()

    for group in groupsInZAxisOrder {
      let itemsInGroup = group.items + otherItems

      // Each `ShapeItemLayer` can only render a single `ShapeItem` that draws a `GGPath`,
      // so we create a separate `ShapeItemLayer` for each path-drawing `ShapeItem`.
      let pathDrawingItemsInGroup = itemsInGroup.filter { $0.drawsCGPath }
      let otherItemsInGroup = itemsInGroup.filter { !$0.drawsCGPath }

      for pathDrawingItem in pathDrawingItemsInGroup {
        let sublayer = ShapeItemLayer(shape: pathDrawingItem, otherItems: otherItemsInGroup)
        contentsLayer.addSublayer(sublayer)
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

extension ShapeItem {
  /// Whether or not this `ShapeItem` is responsible for rendering a `CGPath`
  var drawsCGPath: Bool {
    switch type {
    case .ellipse, .rectangle, .shape, .star:
      return true

    case .fill, .gradientFill, .group, .gradientStroke, .merge,
         .repeater, .round, .stroke, .trim, .transform, .unknown:
      return false
    }
  }
}
