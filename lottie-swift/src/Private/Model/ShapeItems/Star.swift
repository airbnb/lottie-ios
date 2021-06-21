//
//  Star.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

enum StarType: Int, Codable {
  case none
  case star
  case polygon
}

/// An item that define an ellipse shape
final class Star: ShapeItem {
  
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
  
  private enum CodingKeys : String, CodingKey {
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
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Star.CodingKeys.self)
    self.direction = try container.decodeIfPresent(PathDirection.self, forKey: .direction) ?? .clockwise
    self.position = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .position)
    self.outerRadius = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .outerRadius)
    self.outerRoundness = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .outerRoundness)
    self.innerRadius = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .innerRadius)
    self.innerRoundness = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .innerRoundness)
    self.rotation = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .rotation)
    self.points = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .points)
    self.starType = try container.decode(StarType.self, forKey: .starType)
    try super.init(from: decoder)
  }
  
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
  
  required init(dictionary: [String : Any]) throws {
    if let directionRawValue = dictionary[CodingKeys.direction.rawValue] as? Int,
       let direction = PathDirection(rawValue: directionRawValue) {
      self.direction = direction
    } else {
      self.direction = .clockwise
    }
    let positionDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.position.rawValue)
    self.position = try KeyframeGroup<Vector3D>(dictionary: positionDictionary)
    let outerRadiusDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.outerRadius.rawValue)
    self.outerRadius = try KeyframeGroup<Vector1D>(dictionary: outerRadiusDictionary)
    let outerRoundnessDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.outerRoundness.rawValue)
    self.outerRoundness = try KeyframeGroup<Vector1D>(dictionary: outerRoundnessDictionary)
    if let innerRadiusDictionary = dictionary[CodingKeys.innerRadius.rawValue] as? [String: Any] {
      self.innerRadius = try KeyframeGroup<Vector1D>(dictionary: innerRadiusDictionary)
    } else {
      self.innerRadius = nil
    }
    if let innerRoundnessDictionary = dictionary[CodingKeys.innerRoundness.rawValue] as? [String: Any] {
      self.innerRoundness = try KeyframeGroup<Vector1D>(dictionary: innerRoundnessDictionary)
    } else {
      self.innerRoundness = nil
    }
    let rotationDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.rotation.rawValue)
    self.rotation = try KeyframeGroup<Vector1D>(dictionary: rotationDictionary)
    let pointsDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.points.rawValue)
    self.points = try KeyframeGroup<Vector1D>(dictionary: pointsDictionary)
    let starTypeRawValue: Int = try dictionary.valueFor(key: CodingKeys.starType.rawValue)
    guard let starType = StarType(rawValue: starTypeRawValue) else {
      throw InitializableError.invalidInput
    }
    self.starType = starType
    try super.init(dictionary: dictionary)
  }
  
}
