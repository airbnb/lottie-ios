//
//  TextDocument.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

// MARK: - TextJustification

enum TextJustification: Int, Codable {
  case left
  case right
  case center
}

// MARK: - TextDocument

final class TextDocument: Codable, DictionaryInitializable, AnyInitializable {

  // MARK: Lifecycle

  init(dictionary: [String: Any]) throws {
    text = try dictionary.value(for: CodingKeys.text.rawValue)
    fontSize = try dictionary.value(for: CodingKeys.fontSize.rawValue)
    fontFamily = try dictionary.value(for: CodingKeys.fontFamily.rawValue)
    let justificationValue: Int = try dictionary.value(for: CodingKeys.justification.rawValue)
    guard let justification = TextJustification(rawValue: justificationValue) else {
      throw InitializableError.invalidInput
    }
    self.justification = justification
    tracking = try dictionary.value(for: CodingKeys.tracking.rawValue)
    lineHeight = try dictionary.value(for: CodingKeys.lineHeight.rawValue)
    baseline = try dictionary.value(for: CodingKeys.baseline.rawValue)
    if let fillColorRawValue = dictionary[CodingKeys.fillColorData.rawValue] {
      fillColorData = try? Color(value: fillColorRawValue)
    } else {
      fillColorData = nil
    }
    if let strokeColorRawValue = dictionary[CodingKeys.strokeColorData.rawValue] {
      strokeColorData = try? Color(value: strokeColorRawValue)
    } else {
      strokeColorData = nil
    }
    strokeWidth = try? dictionary.value(for: CodingKeys.strokeWidth.rawValue)
    strokeOverFill = try? dictionary.value(for: CodingKeys.strokeOverFill.rawValue)
    if let textFramePositionRawValue = dictionary[CodingKeys.textFramePosition.rawValue] {
      textFramePosition = try? Vector3D(value: textFramePositionRawValue)
    } else {
      textFramePosition = nil
    }
    if let textFrameSizeRawValue = dictionary[CodingKeys.textFrameSize.rawValue] {
      textFrameSize = try? Vector3D(value: textFrameSizeRawValue)
    } else {
      textFrameSize = nil
    }
  }

  convenience init(value: Any) throws {
    guard let dictionary = value as? [String: Any] else {
      throw InitializableError.invalidInput
    }
    try self.init(dictionary: dictionary)
  }

  // MARK: Internal

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

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
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
}
