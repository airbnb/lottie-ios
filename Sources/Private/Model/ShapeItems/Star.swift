//
//  Star.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

// MARK: - StarType

enum StarType: Int, Codable {
  case none
  case star
  case polygon
}

// MARK: - Star

/// An item that define an ellipse shape
final class Star: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Star.CodingKeys.self)
    direction = try container.decodeIfPresent(PathDirection.self, forKey: .direction) ?? .clockwise
    position = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .position)
    outerRadius = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .outerRadius)
    outerRoundness = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .outerRoundness)
    innerRadius = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .innerRadius)
    innerRoundness = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .innerRoundness)
    rotation = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .rotation)
    points = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .points)
    starType = try container.decode(StarType.self, forKey: .starType)
    try super.init(from: decoder)
  }

  // MARK: Internal

  /// The direction of the star.
  let direction: PathDirection

  /// The position of the star
  let position: KeyframeGroup<Vector3D>

  /// The outer radius of the star
  let outerRadius: KeyframeGroup<Vector1D>

  /// The outer roundness of the star
  let outerRoundness: KeyframeGroup<Vector1D>

  /// The outer radius of the star
  let innerRadius: KeyframeGroup<Vector1D>?

  /// The outer roundness of the star
  let innerRoundness: KeyframeGroup<Vector1D>?

  /// The rotation of the star
  let rotation: KeyframeGroup<Vector1D>

  /// The number of points on the star
  let points: KeyframeGroup<Vector1D>

  /// The type of star
  let starType: StarType

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(direction, forKey: .direction)
    try container.encode(position, forKey: .position)
    try container.encode(outerRadius, forKey: .outerRadius)
    try container.encode(outerRoundness, forKey: .outerRoundness)
    try container.encode(innerRadius, forKey: .innerRadius)
    try container.encode(innerRoundness, forKey: .innerRoundness)
    try container.encode(rotation, forKey: .rotation)
    try container.encode(points, forKey: .points)
    try container.encode(starType, forKey: .starType)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case direction = "d"
    case position = "p"
    case outerRadius = "or"
    case outerRoundness = "os"
    case innerRadius = "ir"
    case innerRoundness = "is"
    case rotation = "r"
    case points = "pt"
    case starType = "sy"
  }
}
