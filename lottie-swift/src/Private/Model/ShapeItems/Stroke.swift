//
//  Stroke.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

/// An item that define an ellipse shape
final class Stroke: ShapeItem {
  
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
  
  private enum CodingKeys : String, CodingKey {
    case opacity = "o"
    case color = "c"
    case width = "w"
    case lineCap = "lc"
    case lineJoin = "lj"
    case miterLimit = "ml"
    case dashPattern = "d"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Stroke.CodingKeys.self)
    self.opacity = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .opacity)
    self.color = try container.decode(KeyframeGroup<Color>.self, forKey: .color)
    self.width = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .width)
    self.lineCap = try container.decodeIfPresent(LineCap.self, forKey: .lineCap) ?? .round
    self.lineJoin = try container.decodeIfPresent(LineJoin.self, forKey: .lineJoin) ?? .round
    self.miterLimit = try container.decodeIfPresent(Double.self, forKey: .miterLimit) ?? 4
    self.dashPattern = try container.decodeIfPresent([DashElement].self, forKey: .dashPattern)
    try super.init(from: decoder)
  }
  
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
  
  required init(dictionary: [String : Any]) throws {
    let opacityDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.opacity.rawValue)
    self.opacity = try KeyframeGroup<Vector1D>(dictionary: opacityDictionary)
    let colorDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.color.rawValue)
    self.color = try KeyframeGroup<Color>(dictionary: colorDictionary)
    let widthDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.width.rawValue)
    self.width = try KeyframeGroup<Vector1D>(dictionary: widthDictionary)
    if let lineCapRawValue = dictionary[CodingKeys.lineCap.rawValue] as? Int,
       let lineCap = LineCap(rawValue: lineCapRawValue) {
      self.lineCap = lineCap
    } else {
      self.lineCap = .round
    }
    if let lineJoinRawValue = dictionary[CodingKeys.lineJoin.rawValue] as? Int,
       let lineJoin = LineJoin(rawValue: lineJoinRawValue) {
      self.lineJoin = lineJoin
    } else {
      self.lineJoin = .round
    }
    self.miterLimit = (try? dictionary.valueFor(key: CodingKeys.miterLimit.rawValue)) ?? 4
    let dashPatternDictionaries = dictionary[CodingKeys.dashPattern.rawValue] as? [[String: Any]]
    self.dashPattern = try? dashPatternDictionaries?.map({ try DashElement(dictionary: $0) })
    try super.init(dictionary: dictionary)
  }
}
