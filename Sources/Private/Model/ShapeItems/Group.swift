//
//  GroupItem.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

// MARK: - Group

/// An item that define a a group of shape items
final class Group: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Group.CodingKeys.self)
    items = try container.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .items)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let itemDictionaries: [[String: Any]] = try dictionary.value(for: CodingKeys.items)
    items = try [ShapeItem].fromDictionaries(itemDictionaries)
    try super.init(dictionary: dictionary)
  }

  init(items: [ShapeItem], name: String) {
    self.items = items
    super.init(name: name, type: .group, hidden: false)
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
    case items = "it"
  }
}

// MARK: @unchecked Sendable

/// `Group` inherits `@unchecked Sendable` from `ShapeItem` and
/// we need to restate that here to avoid a warning in Xcode 16
// swiftlint:disable:next no_unchecked_sendable
extension Group: @unchecked Sendable { }
