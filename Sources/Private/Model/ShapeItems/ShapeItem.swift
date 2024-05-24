//
//  ShapeItem.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

// MARK: - ShapeType

enum ShapeType: String, Codable, Sendable {
  case ellipse = "el"
  case fill = "fl"
  case gradientFill = "gf"
  case group = "gr"
  case gradientStroke = "gs"
  case merge = "mm"
  case rectangle = "rc"
  case repeater = "rp"
  case round = "rd"
  case shape = "sh"
  case star = "sr"
  case stroke = "st"
  case trim = "tm"
  case transform = "tr"
  case unknown

  public init(from decoder: Decoder) throws {
    self = try ShapeType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
}

// MARK: ClassFamily

extension ShapeType: ClassFamily {

  static var discriminator: Discriminator = .type

  func getType() -> AnyObject.Type {
    switch self {
    case .ellipse:
      Ellipse.self
    case .fill:
      Fill.self
    case .gradientFill:
      GradientFill.self
    case .group:
      Group.self
    case .gradientStroke:
      GradientStroke.self
    case .merge:
      Merge.self
    case .rectangle:
      Rectangle.self
    case .repeater:
      Repeater.self
    case .round:
      RoundedCorners.self
    case .shape:
      Shape.self
    case .star:
      Star.self
    case .stroke:
      Stroke.self
    case .trim:
      Trim.self
    case .transform:
      ShapeTransform.self
    default:
      ShapeItem.self
    }
  }
}

// MARK: - ShapeItem

/// An item belonging to a Shape Layer
class ShapeItem: Codable, DictionaryInitializable {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeItem.CodingKeys.self)
    name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Layer"
    type = try container.decode(ShapeType.self, forKey: .type)
    hidden = try container.decodeIfPresent(Bool.self, forKey: .hidden) ?? false
  }

  required init(dictionary: [String: Any]) throws {
    name = (try? dictionary.value(for: CodingKeys.name)) ?? "Layer"
    type = ShapeType(rawValue: try dictionary.value(for: CodingKeys.type)) ?? .unknown
    hidden = (try? dictionary.value(for: CodingKeys.hidden)) ?? false
  }

  init(
    name: String,
    type: ShapeType,
    hidden: Bool)
  {
    self.name = name
    self.type = type
    self.hidden = hidden
  }

  // MARK: Internal

  /// The name of the shape
  let name: String

  /// The type of shape
  let type: ShapeType

  let hidden: Bool

  // MARK: Fileprivate

  fileprivate enum CodingKeys: String, CodingKey {
    case name = "nm"
    case type = "ty"
    case hidden = "hd"
  }
}

extension [ShapeItem] {

  static func fromDictionaries(_ dictionaries: [[String: Any]]) throws -> [ShapeItem] {
    try dictionaries.compactMap { dictionary in
      let shapeType = dictionary[ShapeItem.CodingKeys.type.rawValue] as? String
      switch ShapeType(rawValue: shapeType ?? ShapeType.unknown.rawValue) {
      case .ellipse:
        return try Ellipse(dictionary: dictionary)
      case .fill:
        return try Fill(dictionary: dictionary)
      case .gradientFill:
        return try GradientFill(dictionary: dictionary)
      case .group:
        return try Group(dictionary: dictionary)
      case .gradientStroke:
        return try GradientStroke(dictionary: dictionary)
      case .merge:
        return try Merge(dictionary: dictionary)
      case .rectangle:
        return try Rectangle(dictionary: dictionary)
      case .repeater:
        return try Repeater(dictionary: dictionary)
      case .round:
        return try RoundedCorners(dictionary: dictionary)
      case .shape:
        return try Shape(dictionary: dictionary)
      case .star:
        return try Star(dictionary: dictionary)
      case .stroke:
        return try Stroke(dictionary: dictionary)
      case .trim:
        return try Trim(dictionary: dictionary)
      case .transform:
        return try ShapeTransform(dictionary: dictionary)
      case .none:
        return nil
      default:
        return try ShapeItem(dictionary: dictionary)
      }
    }
  }
}

// MARK: - ShapeItem + Sendable

/// Since `ShapeItem` isn't `final`, we have to use `@unchecked Sendable` instead of `Sendable.`
/// All `ShapeItem` subclasses are immutable `Sendable` values.
// swiftlint:disable:next no_unchecked_sendable
extension ShapeItem: @unchecked Sendable { }
