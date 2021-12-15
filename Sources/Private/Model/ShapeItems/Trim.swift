//
//  Trim.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

// MARK: - TrimType

enum TrimType: Int, Codable {
  case simultaneously = 1
  case individually = 2
}

// MARK: - Trim

/// An item that define an ellipse shape
final class Trim: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Trim.CodingKeys.self)
    start = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .start)
    end = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .end)
    offset = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .offset)
    trimType = try container.decode(TrimType.self, forKey: .trimType)
    try super.init(from: decoder)
  }

  // MARK: Internal

  /// The start of the trim
  let start: KeyframeGroup<Vector1D>

  /// The end of the trim
  let end: KeyframeGroup<Vector1D>

  /// The offset of the trim
  let offset: KeyframeGroup<Vector1D>

  let trimType: TrimType

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(start, forKey: .start)
    try container.encode(end, forKey: .end)
    try container.encode(offset, forKey: .offset)
    try container.encode(trimType, forKey: .trimType)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case start = "s"
    case end = "e"
    case offset = "o"
    case trimType = "m"
  }
}
