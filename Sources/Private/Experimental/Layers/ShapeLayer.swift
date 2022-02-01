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
    setupGroups(from: shapeLayer.items, parentGroup: nil)
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

// MARK: - GroupLayer

/// The CALayer type responsible for rendering `Group`s
final class GroupLayer: BaseAnimationLayer {

  // MARK: Lifecycle

  init(group: Group, inheritedItems: [ShapeItemLayer.Item]) {
    self.group = group
    self.inheritedItems = inheritedItems
    super.init()
    setupLayerHierarchy()
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

    group = typedLayer.group
    inheritedItems = typedLayer.inheritedItems
    super.init(layer: typedLayer)
  }

  // MARK: Private

  private let group: Group

  /// `ShapeItem`s that were listed in the parent's `items: [ShapeItem]` array
  ///   - This layer's parent is either the root `ShapeLayerModel` or some other `Group`
  private let inheritedItems: [ShapeItemLayer.Item]

  private func setupLayerHierarchy() {
    // Groups can contain other groups, so we may have to continue
    // recursively creating more `GroupLayer`s
    setupGroups(from: group.items, parentGroup: group)

    let nonGroupItems = group.items
      .filter { !($0 is Group) }
      .map { ShapeItemLayer.Item(item: $0, parentGroup: group) }
      + inheritedItems

    let (pathDrawingItemsInGroup, otherItemsInGroup) = nonGroupItems.grouped(by: \.item.drawsCGPath)

    // If all of the path-drawing `ShapeItem`s have keyframes with the same timing information,
    // we can combine the `[KeyframeGroup<BezierPath>]` (which have to animate in separate layers)
    // into a single `KeyframeGroup<[BezierPath]>`, which can be combined into a single CGPath animation.
    //
    // This is how Groups with multiple path-drawing items are supposed to be rendered,
    // because combining multiple paths into a single `CGPath` (instead of rendering them in separate layers)
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

extension CALayer {
  /// Sets up `GroupLayer`s for each `Group` in the given list of `ShapeItem`s
  ///  - Each `Group` item becomes its own `GroupLayer` sublayer.
  ///  - Other `ShapeItem` are applied to all sublayers
  fileprivate func setupGroups(from items: [ShapeItem], parentGroup: Group?) {
    let (groupItems, otherItems) = items.grouped(by: { $0 is Group })

    // Groups are listed from front to back,
    // but `CALayer.sublayers` are listed from back to front.
    let groupsInZAxisOrder = groupItems.reversed()

    for group in groupsInZAxisOrder {
      guard let group = group as? Group else { continue }

      let groupLayer = GroupLayer(
        group: group,
        inheritedItems: Array(otherItems.map {
          ShapeItemLayer.Item(item: $0, parentGroup: parentGroup)
        }))

      addSublayer(groupLayer)
    }
  }
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

extension Collection {
  /// Splits this collection into two groups, based on the given predicate
  func grouped(by predicate: (Element) -> Bool) -> (trueElements: [Element], falseElements: [Element]) {
    var trueElements = [Element]()
    var falseElements = [Element]()

    for element in self {
      if predicate(element) {
        trueElements.append(element)
      } else {
        falseElements.append(element)
      }
    }

    return (trueElements, falseElements)
  }
}
