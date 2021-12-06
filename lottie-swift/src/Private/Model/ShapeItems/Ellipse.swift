//
//  EllipseItem.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

// MARK: - PathDirection

enum PathDirection: Int, Codable {
  case clockwise = 1
  case userSetClockwise = 2
  case counterClockwise = 3
}

// MARK: - Ellipse

/// An item that define an ellipse shape
final class Ellipse: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Ellipse.CodingKeys.self)
    direction = try container.decodeIfPresent(PathDirection.self, forKey: .direction) ?? .clockwise
    position = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .position)
    size = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .size)
    try super.init(from: decoder)
  }

  // MARK: Internal

  /// The direction of the ellipse.
  let direction: PathDirection

  /// The position of the ellipse
  let position: KeyframeGroup<Vector3D>

  /// The size of the ellipse
  let size: KeyframeGroup<Vector3D>

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(direction, forKey: .direction)
    try container.encode(position, forKey: .position)
    try container.encode(size, forKey: .size)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case direction = "d"
    case position = "p"
    case size = "s"
  }
}
