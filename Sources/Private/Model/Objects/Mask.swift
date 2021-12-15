//
//  Mask.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

// MARK: - MaskMode

enum MaskMode: String, Codable {
  case add = "a"
  case subtract = "s"
  case intersect = "i"
  case lighten = "l"
  case darken = "d"
  case difference = "f"
  case none = "n"
}

// MARK: - Mask

final class Mask: Codable {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Mask.CodingKeys.self)
    mode = try container.decodeIfPresent(MaskMode.self, forKey: .mode) ?? .add
    opacity = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .opacity) ?? KeyframeGroup(Vector1D(100))
    shape = try container.decode(KeyframeGroup<BezierPath>.self, forKey: .shape)
    inverted = try container.decodeIfPresent(Bool.self, forKey: .inverted) ?? false
    expansion = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .expansion) ?? KeyframeGroup(Vector1D(0))
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case mode = "mode"
    case opacity = "o"
    case inverted = "inv"
    case shape = "pt"
    case expansion = "x"
  }

  let mode: MaskMode

  let opacity: KeyframeGroup<Vector1D>

  let shape: KeyframeGroup<BezierPath>

  let inverted: Bool

  let expansion: KeyframeGroup<Vector1D>
}
