//
//  TextDocument.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

enum TextJustification: Int, Codable {
  case left
  case right
  case center
}

final class TextDocument: Codable, DictionaryInitializable, AnyInitializable {
  
  /// The Text
  let text: String
  
  /// The Font size
  let fontSize: Double
  
  /// The Font Family
  let fontFamily: String
  
  /// Justification
  let justification: TextJustification
  
  /// Tracking
  let tracking: Int
  
  /// Line Height
  let lineHeight: Double
  
  /// Baseline
  let baseline: Double?
  
  /// Fill Color data
  let fillColorData: Color?
  
  /// Scroke Color data
  let strokeColorData: Color?
  
  /// Stroke Width
  let strokeWidth: Double?
  
  /// Stroke Over Fill
  let strokeOverFill: Bool?
  
  let textFramePosition: Vector3D?
  
  let textFrameSize: Vector3D?
  
  private enum CodingKeys : String, CodingKey {
    case text = "t"
    case fontSize = "s"
    case fontFamily = "f"
    case justification = "j"
    case tracking = "tr"
    case lineHeight = "lh"
    case baseline = "ls"
    case fillColorData = "fc"
    case strokeColorData = "sc"
    case strokeWidth = "sw"
    case strokeOverFill = "of"
    case textFramePosition = "ps"
    case textFrameSize = "sz"
  }
  
  init(dictionary: [String : Any]) throws {
    self.text = try dictionary.valueFor(key: CodingKeys.text.rawValue)
    self.fontSize = try dictionary.valueFor(key: CodingKeys.fontSize.rawValue)
    self.fontFamily = try dictionary.valueFor(key: CodingKeys.fontFamily.rawValue)
    let justificationValue: Int = try dictionary.valueFor(key: CodingKeys.justification.rawValue)
    guard let justification = TextJustification(rawValue: justificationValue) else {
      throw InitializableError.invalidInput
    }
    self.justification = justification
    self.tracking = try dictionary.valueFor(key: CodingKeys.tracking.rawValue)
    self.lineHeight = try dictionary.valueFor(key: CodingKeys.lineHeight.rawValue)
    self.baseline = try dictionary.valueFor(key: CodingKeys.baseline.rawValue)
    if let fillColorRawValue = dictionary[CodingKeys.fillColorData.rawValue] {
      self.fillColorData = try? Color(value: fillColorRawValue)
    } else {
      self.fillColorData = nil
    }
    if let strokeColorRawValue = dictionary[CodingKeys.strokeColorData.rawValue] {
      self.strokeColorData = try? Color(value: strokeColorRawValue)
    } else {
      self.strokeColorData = nil
    }
    self.strokeWidth = try? dictionary.valueFor(key: CodingKeys.strokeWidth.rawValue)
    self.strokeOverFill = try? dictionary.valueFor(key: CodingKeys.strokeOverFill.rawValue)
    if let textFramePositionRawValue = dictionary[CodingKeys.textFramePosition.rawValue] {
      self.textFramePosition = try? Vector3D(value: textFramePositionRawValue)
    } else {
      self.textFramePosition = nil
    }
    if let textFrameSizeRawValue = dictionary[CodingKeys.textFrameSize.rawValue] {
      self.textFrameSize = try? Vector3D(value: textFrameSizeRawValue)
    } else {
      self.textFrameSize = nil
    }
  }
  
  convenience init(value: Any) throws {
    guard let dictionary = value as? [String: Any] else {
      throw InitializableError.invalidInput
    }
    try self.init(dictionary: dictionary)
  }
}
