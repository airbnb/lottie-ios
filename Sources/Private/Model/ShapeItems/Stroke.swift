//
//  Stroke.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

final class Stroke: ShapeItem {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Stroke.CodingKeys.self)
    opacity = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .opacity)
    color = try container.decode(KeyframeGroup<Color>.self, forKey: .color)
    width = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .width)
    lineCap = try container.decodeIfPresent(LineCap.self, forKey: .lineCap) ?? .round
    lineJoin = try container.decodeIfPresent(LineJoin.self, forKey: .lineJoin) ?? .round
    miterLimit = try container.decodeIfPresent(Double.self, forKey: .miterLimit) ?? 4
    dashPattern = try container.decodeIfPresent([DashElement].self, forKey: .dashPattern)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let opacityDictionary: [String: Any] = try dictionary.value(for: CodingKeys.opacity)
    opacity = try KeyframeGroup<Vector1D>(dictionary: opacityDictionary)
    let colorDictionary: [String: Any] = try dictionary.value(for: CodingKeys.color)
    color = try KeyframeGroup<Color>(dictionary: colorDictionary)
    let widthDictionary: [String: Any] = try dictionary.value(for: CodingKeys.width)
    width = try KeyframeGroup<Vector1D>(dictionary: widthDictionary)
    if
      let lineCapRawValue = dictionary[CodingKeys.lineCap.rawValue] as? Int,
      let lineCap = LineCap(rawValue: lineCapRawValue)
    {
      self.lineCap = lineCap
    } else {
      lineCap = .round
    }
    if
      let lineJoinRawValue = dictionary[CodingKeys.lineJoin.rawValue] as? Int,
      let lineJoin = LineJoin(rawValue: lineJoinRawValue)
    {
      self.lineJoin = lineJoin
    } else {
      lineJoin = .round
    }
    miterLimit = (try? dictionary.value(for: CodingKeys.miterLimit)) ?? 4
    let dashPatternDictionaries = dictionary[CodingKeys.dashPattern.rawValue] as? [[String: Any]]
    dashPattern = try? dashPatternDictionaries?.map({ try DashElement(dictionary: $0) })
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// The opacity of the stroke
  let opacity: KeyframeGroup<Vector1D>

  /// The Color of the stroke
  let color: KeyframeGroup<Color>

  /// The width of the stroke
  let width: KeyframeGroup<Vector1D>

  /// Line Cap
  let lineCap: LineCap

  /// Line Join
  let lineJoin: LineJoin

  /// Miter Limit
  let miterLimit: Double

  /// The dash pattern of the stroke
  let dashPattern: [DashElement]?

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(color, forKey: .color)
    try container.encode(width, forKey: .width)
    try container.encode(lineCap, forKey: .lineCap)
    try container.encode(lineJoin, forKey: .lineJoin)
    try container.encode(miterLimit, forKey: .miterLimit)
    try container.encodeIfPresent(dashPattern, forKey: .dashPattern)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case opacity = "o"
    case color = "c"
    case width = "w"
    case lineCap = "lc"
    case lineJoin = "lj"
    case miterLimit = "ml"
    case dashPattern = "d"
  }
}
