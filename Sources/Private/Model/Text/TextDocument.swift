//
//  TextDocument.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

// MARK: - TextJustification

enum TextJustification: Int, Codable {
  case left
  case right
  case center
  case justifyLastLineLeft
  case justifyLastLineRight
  case justifyLastLineCenter
  case justifyLastLineFull
}

// MARK: - TextDocument

final class TextDocument: Codable, DictionaryInitializable, AnyInitializable {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = try container.decode(String.self, forKey: .text)
    fontSize = try container.decode(Double.self, forKey: .fontSize)
    fontFamily = try container.decode(String.self, forKey: .fontFamily)
    justification = try container.decode(TextJustification.self, forKey: .justification)
    tracking = try container.decode(Int.self, forKey: .tracking)
    lineHeight = try container.decodeIfPresent(Double.self, forKey: .lineHeight) ?? 0
    baseline = try container.decodeIfPresent(Double.self, forKey: .baseline)
    fillColorData = try container.decodeIfPresent(LottieColor.self, forKey: .fillColorData)
    strokeColorData = try container.decodeIfPresent(LottieColor.self, forKey: .strokeColorData)
    strokeWidth = try container.decodeIfPresent(Double.self, forKey: .strokeWidth)
    strokeOverFill = try container.decodeIfPresent(Bool.self, forKey: .strokeOverFill)
    textFramePosition = try container.decodeIfPresent(LottieVector3D.self, forKey: .textFramePosition)
    textFrameSize = try container.decodeIfPresent(LottieVector3D.self, forKey: .textFrameSize)
  }

  init(dictionary: [String: Any]) throws {
    text = try dictionary.value(for: CodingKeys.text)
    fontSize = try dictionary.value(for: CodingKeys.fontSize)
    fontFamily = try dictionary.value(for: CodingKeys.fontFamily)
    let justificationValue: Int = try dictionary.value(for: CodingKeys.justification)
    guard let justification = TextJustification(rawValue: justificationValue) else {
      throw InitializableError.invalidInput()
    }
    self.justification = justification
    tracking = try dictionary.value(for: CodingKeys.tracking)
    lineHeight = (try? dictionary.value(for: CodingKeys.lineHeight)) ?? 0
    baseline = try dictionary.value(for: CodingKeys.baseline)
    if let fillColorRawValue = dictionary[CodingKeys.fillColorData.rawValue] {
      fillColorData = try? LottieColor(value: fillColorRawValue)
    } else {
      fillColorData = nil
    }
    if let strokeColorRawValue = dictionary[CodingKeys.strokeColorData.rawValue] {
      strokeColorData = try? LottieColor(value: strokeColorRawValue)
    } else {
      strokeColorData = nil
    }
    strokeWidth = try? dictionary.value(for: CodingKeys.strokeWidth)
    strokeOverFill = try? dictionary.value(for: CodingKeys.strokeOverFill)
    if let textFramePositionRawValue = dictionary[CodingKeys.textFramePosition.rawValue] {
      textFramePosition = try? LottieVector3D(value: textFramePositionRawValue)
    } else {
      textFramePosition = nil
    }
    if let textFrameSizeRawValue = dictionary[CodingKeys.textFrameSize.rawValue] {
      textFrameSize = try? LottieVector3D(value: textFrameSizeRawValue)
    } else {
      textFrameSize = nil
    }
  }

  convenience init(value: Any) throws {
    guard let dictionary = value as? [String: Any] else {
      throw InitializableError.invalidInput()
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
  let fillColorData: LottieColor?

  /// Scroke Color data
  let strokeColorData: LottieColor?

  /// Stroke Width
  let strokeWidth: Double?

  /// Stroke Over Fill
  let strokeOverFill: Bool?

  let textFramePosition: LottieVector3D?

  let textFrameSize: LottieVector3D?

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
