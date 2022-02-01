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

    let otherItems = shapeLayer.items
      .filter { !($0 is Group) }
      .map { ShapeItemLayer.Item(item: $0, parentGroup: nil) }

    // Groups are listed from front to back,
    // but `CALayer.sublayers` are listed from back to front.
    let groupsInZAxisOrder = groupItems.reversed()

    for group in groupsInZAxisOrder {
      let itemsInGroup = group.items.map { ShapeItemLayer.Item(item: $0, parentGroup: group) }
        + otherItems

      let pathDrawingItemsInGroup = itemsInGroup.filter { $0.item.drawsCGPath }
      let otherItemsInGroup = itemsInGroup.filter { !$0.item.drawsCGPath }

      // If all of the path-drawing `ShapeItem`s have keyframes with the same timing information,
      // we can combine the `[KeyframeGroup<BezierPath>]` (which have to animate in separate layers)
      // into a single `KeyframeGroup<[BezierPath]>`, which can be combined into a single CGPath animation.
      //
      // This is how Groups with multiple path-drawing items are supposed to be rendered,
      // because combing multiple paths into a single `CGPath` (instead of render them in separate layers)
      // allows `CAShapeLayerFillRule.evenOdd` to be applied if the paths overlap. We just can't do this
      // in all cases, due to limitations of Core Animation.
      if
        pathDrawingItemsInGroup.count > 1,
        let combinedShapeKeyframes = Keyframes.combinedIfPossible(pathDrawingItemsInGroup.map {
          ($0.item as? Shape)?.path
        }),
        // `Trim`s are currently only applied correctly using individual `ShapeItemLayer`s,
        // because each path has to be trimmed separately.
        !otherItemsInGroup.contains(where: { $0.item.type == .trim })
      {
        let combinedShape = CombinedShapeItem(
          shapes: combinedShapeKeyframes,
          name: group.name)

        let sublayer = ShapeItemLayer(
          shape: ShapeItemLayer.Item(item: combinedShape, parentGroup: group),
          otherItems: otherItemsInGroup)

        addSublayer(sublayer)
      }

      // Otherwise, if each `ShapeItem` that draws a `GGPath` animates independently,
      // we have to create a separate `ShapeItemLayer` for each one.
      else {
        for pathDrawingItem in pathDrawingItemsInGroup {
          let sublayer = ShapeItemLayer(shape: pathDrawingItem, otherItems: otherItemsInGroup)
          addSublayer(sublayer)
        }
      }
    }
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

    shapeLayer = typedLayer.shapeLayer
    super.init(layer: typedLayer)
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
