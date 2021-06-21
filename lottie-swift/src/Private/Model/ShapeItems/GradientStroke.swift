//
//  GradientStroke.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

enum LineCap: Int, Codable {
  case none
  case butt
  case round
  case square
}

enum LineJoin: Int, Codable {
  case none
  case miter
  case round
  case bevel
}

/// An item that define an ellipse shape
final class GradientStroke: ShapeItem {
  
  /// The opacity of the fill
  let opacity: KeyframeGroup<Vector1D>
  
  /// The start of the gradient
  let startPoint: KeyframeGroup<Vector3D>
  
  /// The end of the gradient
  let endPoint: KeyframeGroup<Vector3D>
  
  /// The type of gradient
  let gradientType: GradientType
  
  /// Gradient Highlight Length. Only if type is Radial
  let highlightLength: KeyframeGroup<Vector1D>?
  
  /// Highlight Angle. Only if type is Radial
  let highlightAngle: KeyframeGroup<Vector1D>?
  
  /// The number of color points in the gradient
  let numberOfColors: Int
  
  /// The Colors of the gradient.
  let colors: KeyframeGroup<[Double]>
  
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
    case startPoint = "s"
    case endPoint = "e"
    case gradientType = "t"
    case highlightLength = "h"
    case highlightAngle = "a"
    case colors = "g"
    case width = "w"
    case lineCap = "lc"
    case lineJoin = "lj"
    case miterLimit = "ml"
    case dashPattern = "d"
  }
  
  private enum GradientDataKeys : String, CodingKey {
    case numberOfColors = "p"
    case colors = "k"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: GradientStroke.CodingKeys.self)
    self.opacity = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .opacity)
    self.startPoint = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .startPoint)
    self.endPoint = try container.decode(KeyframeGroup<Vector3D>.self, forKey: .endPoint)
    self.gradientType = try container.decode(GradientType.self, forKey: .gradientType)
    self.highlightLength = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .highlightLength)
    self.highlightAngle = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .highlightAngle)
    self.width = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .width)
    self.lineCap = try container.decodeIfPresent(LineCap.self, forKey: .lineCap) ?? .round
    self.lineJoin = try container.decodeIfPresent(LineJoin.self, forKey: .lineJoin) ?? .round
    self.miterLimit = try container.decodeIfPresent(Double.self, forKey: .miterLimit) ?? 4
    // TODO Decode Color Objects instead of array.
    let colorsContainer = try container.nestedContainer(keyedBy: GradientDataKeys.self, forKey: .colors)
    self.colors = try colorsContainer.decode(KeyframeGroup<[Double]>.self, forKey: .colors)
    self.numberOfColors = try colorsContainer.decode(Int.self, forKey: .numberOfColors)
    self.dashPattern = try container.decodeIfPresent([DashElement].self, forKey: .dashPattern)
    try super.init(from: decoder)
  }
  
  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(startPoint, forKey: .startPoint)
    try container.encode(endPoint, forKey: .endPoint)
    try container.encode(gradientType, forKey: .gradientType)
    try container.encodeIfPresent(highlightLength, forKey: .highlightLength)
    try container.encodeIfPresent(highlightAngle, forKey: .highlightAngle)
    try container.encode(width, forKey: .width)
    try container.encode(lineCap, forKey: .lineCap)
    try container.encode(lineJoin, forKey: .lineJoin)
    try container.encode(miterLimit, forKey: .miterLimit)
    var colorsContainer = container.nestedContainer(keyedBy: GradientDataKeys.self, forKey: .colors)
    try colorsContainer.encode(numberOfColors, forKey: .numberOfColors)
    try colorsContainer.encode(colors, forKey: .colors)
    try container.encodeIfPresent(dashPattern, forKey: .dashPattern)
  }
  
  required init(dictionary: [String : Any]) throws {
    let opacityDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.opacity.rawValue)
    self.opacity = try KeyframeGroup<Vector1D>(dictionary: opacityDictionary)
    let startPointDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.startPoint.rawValue)
    self.startPoint = try KeyframeGroup<Vector3D>(dictionary: startPointDictionary)
    let endPointDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.endPoint.rawValue)
    self.endPoint = try KeyframeGroup<Vector3D>(dictionary: endPointDictionary)
    let gradientRawType: Int = try dictionary.valueFor(key: CodingKeys.gradientType.rawValue)
    guard let gradient = GradientType(rawValue: gradientRawType) else {
      throw InitializableError.invalidInput
    }
    self.gradientType = gradient
    if let highlightLengthDictionary = dictionary[CodingKeys.highlightLength.rawValue] as? [String: Any] {
      self.highlightLength = try? KeyframeGroup<Vector1D>(dictionary: highlightLengthDictionary)
    } else {
      self.highlightLength = nil
    }
    if let highlightAngleDictionary = dictionary[CodingKeys.highlightAngle.rawValue] as? [String: Any] {
      self.highlightAngle = try? KeyframeGroup<Vector1D>(dictionary: highlightAngleDictionary)
    } else {
      self.highlightAngle = nil
    }
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
    let colorsDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.colors.rawValue)
    let nestedColorsDictionary: [String: Any] = try colorsDictionary.valueFor(key: GradientDataKeys.colors.rawValue)
    self.colors = try KeyframeGroup<[Double]>(dictionary: nestedColorsDictionary)
    self.numberOfColors = try colorsDictionary.valueFor(key: GradientDataKeys.numberOfColors.rawValue)
    let dashPatternDictionaries = dictionary[CodingKeys.dashPattern.rawValue] as? [[String: Any]]
    self.dashPattern = try? dashPatternDictionaries?.map({ try DashElement(dictionary: $0) })
    try super.init(dictionary: dictionary)
  }
  
}
