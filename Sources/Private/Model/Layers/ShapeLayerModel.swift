//
//  ShapeLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

// MARK: - ShapeLayerModel

/// A layer that holds vector shape objects.
final class ShapeLayerModel: LayerModel {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeLayerModel.CodingKeys.self)
    items = try container.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .items)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let itemDictionaries: [[String: Any]] = try dictionary.value(for: CodingKeys.items)
    items = try [ShapeItem].fromDictionaries(itemDictionaries)
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// A list of shape items.
  let items: [ShapeItem]

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(items, forKey: .items)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case items = "shapes"
  }
}

// MARK: @unchecked Sendable

/// `ShapeLayerModel` inherits `@unchecked Sendable` from `LayerModel` and
/// we need to restate that here to avoid a warning in Xcode 16
// swiftlint:disable:next no_unchecked_sendable
extension ShapeLayerModel: @unchecked Sendable { }
