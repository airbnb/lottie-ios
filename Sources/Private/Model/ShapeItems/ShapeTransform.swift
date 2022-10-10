//
//  TransformItem.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

final class ShapeTransform: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeTransform.CodingKeys.self)
    anchor = try container
      .decodeIfPresent(KeyframeGroup<LottieVector3D>.self, forKey: .anchor) ??
      KeyframeGroup(LottieVector3D(x: Double(0), y: 0, z: 0))
    position = try container
      .decodeIfPresent(KeyframeGroup<LottieVector3D>.self, forKey: .position) ??
      KeyframeGroup(LottieVector3D(x: Double(0), y: 0, z: 0))
    scale = try container
      .decodeIfPresent(KeyframeGroup<LottieVector3D>.self, forKey: .scale) ??
      KeyframeGroup(LottieVector3D(x: Double(100), y: 100, z: 100))
    rotation = try container
      .decodeIfPresent(KeyframeGroup<LottieVector1D>.self, forKey: .rotation) ?? KeyframeGroup(LottieVector1D(0))
    opacity = try container
      .decodeIfPresent(KeyframeGroup<LottieVector1D>.self, forKey: .opacity) ?? KeyframeGroup(LottieVector1D(100))
    skew = try container.decodeIfPresent(KeyframeGroup<LottieVector1D>.self, forKey: .skew) ?? KeyframeGroup(LottieVector1D(0))
    skewAxis = try container
      .decodeIfPresent(KeyframeGroup<LottieVector1D>.self, forKey: .skewAxis) ?? KeyframeGroup(LottieVector1D(0))
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    if
      let anchorDictionary = dictionary[CodingKeys.anchor.rawValue] as? [String: Any],
      let anchor = try? KeyframeGroup<LottieVector3D>(dictionary: anchorDictionary)
    {
      self.anchor = anchor
    } else {
      anchor = KeyframeGroup(LottieVector3D(x: Double(0), y: 0, z: 0))
    }
    if
      let positionDictionary = dictionary[CodingKeys.position.rawValue] as? [String: Any],
      let position = try? KeyframeGroup<LottieVector3D>(dictionary: positionDictionary)
    {
      self.position = position
    } else {
      position = KeyframeGroup(LottieVector3D(x: Double(0), y: 0, z: 0))
    }
    if
      let scaleDictionary = dictionary[CodingKeys.scale.rawValue] as? [String: Any],
      let scale = try? KeyframeGroup<LottieVector3D>(dictionary: scaleDictionary)
    {
      self.scale = scale
    } else {
      scale = KeyframeGroup(LottieVector3D(x: Double(100), y: 100, z: 100))
    }
    if
      let rotationDictionary = dictionary[CodingKeys.rotation.rawValue] as? [String: Any],
      let rotation = try? KeyframeGroup<LottieVector1D>(dictionary: rotationDictionary)
    {
      self.rotation = rotation
    } else {
      rotation = KeyframeGroup(LottieVector1D(0))
    }
    if
      let opacityDictionary = dictionary[CodingKeys.opacity.rawValue] as? [String: Any],
      let opacity = try? KeyframeGroup<LottieVector1D>(dictionary: opacityDictionary)
    {
      self.opacity = opacity
    } else {
      opacity = KeyframeGroup(LottieVector1D(100))
    }
    if
      let skewDictionary = dictionary[CodingKeys.skew.rawValue] as? [String: Any],
      let skew = try? KeyframeGroup<LottieVector1D>(dictionary: skewDictionary)
    {
      self.skew = skew
    } else {
      skew = KeyframeGroup(LottieVector1D(0))
    }
    if
      let skewAxisDictionary = dictionary[CodingKeys.skewAxis.rawValue] as? [String: Any],
      let skewAxis = try? KeyframeGroup<LottieVector1D>(dictionary: skewAxisDictionary)
    {
      self.skewAxis = skewAxis
    } else {
      skewAxis = KeyframeGroup(LottieVector1D(0))
    }
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// Anchor Point
  let anchor: KeyframeGroup<LottieVector3D>

  /// Position
  let position: KeyframeGroup<LottieVector3D>

  /// Scale
  let scale: KeyframeGroup<LottieVector3D>

  /// Rotation
  let rotation: KeyframeGroup<LottieVector1D>

  /// opacity
  let opacity: KeyframeGroup<LottieVector1D>

  /// Skew
  let skew: KeyframeGroup<LottieVector1D>

  /// Skew Axis
  let skewAxis: KeyframeGroup<LottieVector1D>

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(anchor, forKey: .anchor)
    try container.encode(position, forKey: .position)
    try container.encode(scale, forKey: .scale)
    try container.encode(rotation, forKey: .rotation)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(skew, forKey: .skew)
    try container.encode(skewAxis, forKey: .skewAxis)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case anchor = "a"
    case position = "p"
    case scale = "s"
    case rotation = "r"
    case opacity = "o"
    case skew = "sk"
    case skewAxis = "sa"
  }
}
