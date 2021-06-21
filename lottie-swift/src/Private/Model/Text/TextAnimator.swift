//
//  TextAnimator.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

final class TextAnimator: Codable, DictionaryInitializable {
  
  let name: String
  
  /// Anchor
  let anchor: KeyframeGroup<Vector3D>?
  
  /// Position
  let position: KeyframeGroup<Vector3D>?
  
  /// Scale
  let scale: KeyframeGroup<Vector3D>?
  
  /// Skew
  let skew: KeyframeGroup<Vector1D>?
  
  /// Skew Axis
  let skewAxis: KeyframeGroup<Vector1D>?
  
  /// Rotation
  let rotation: KeyframeGroup<Vector1D>?
  
  /// Opacity
  let opacity: KeyframeGroup<Vector1D>?
  
  /// Stroke Color
  let strokeColor: KeyframeGroup<Color>?
  
  /// Fill Color
  let fillColor: KeyframeGroup<Color>?
  
  /// Stroke Width
  let strokeWidth: KeyframeGroup<Vector1D>?
  
  /// Tracking
  let tracking: KeyframeGroup<Vector1D>?
  
  private enum CodingKeys: String, CodingKey {
//    case textSelector = "s" TODO
    case textAnimator = "a"
    case name = "nm"
  }
  
  private enum TextSelectorKeys: String, CodingKey {
    case start = "s"
    case end = "e"
    case offset = "o"
  }
  
  private enum TextAnimatorKeys: String, CodingKey {
    case fillColor = "fc"
    case strokeColor = "sc"
    case strokeWidth = "sw"
    case tracking = "t"
    case anchor = "a"
    case position = "p"
    case scale = "s"
    case skew = "sk"
    case skewAxis = "sa"
    case rotation = "r"
    case opacity = "o"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: TextAnimator.CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    let animatorContainer = try container.nestedContainer(keyedBy: TextAnimatorKeys.self, forKey: .textAnimator)
    self.fillColor = try animatorContainer.decodeIfPresent(KeyframeGroup<Color>.self, forKey: .fillColor)
    self.strokeColor = try animatorContainer.decodeIfPresent(KeyframeGroup<Color>.self, forKey: .strokeColor)
    self.strokeWidth = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .strokeWidth)
    self.tracking = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .tracking)
    self.anchor = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .anchor)
    self.position = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .position)
    self.scale = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .scale)
    self.skew = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .skew)
    self.skewAxis = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .skewAxis)
    self.rotation = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotation)
    self.opacity = try animatorContainer.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .opacity)
    
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    var animatorContainer = container.nestedContainer(keyedBy: TextAnimatorKeys.self, forKey: .textAnimator)
    try animatorContainer.encodeIfPresent(fillColor, forKey: .fillColor)
    try animatorContainer.encodeIfPresent(strokeColor, forKey: .strokeColor)
    try animatorContainer.encodeIfPresent(strokeWidth, forKey: .strokeWidth)
    try animatorContainer.encodeIfPresent(tracking, forKey: .tracking)
  }
  
  init(dictionary: [String : Any]) throws {
    self.name = (try? dictionary.valueFor(key: CodingKeys.name.rawValue)) ?? ""
    let animatorDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.textAnimator.rawValue)
    if let fillColorDictionary = animatorDictionary[TextAnimatorKeys.fillColor.rawValue] as? [String: Any] {
      self.fillColor = try? KeyframeGroup<Color>(dictionary: fillColorDictionary)
    } else {
      self.fillColor = nil
    }
    if let strokeColorDictionary = animatorDictionary[TextAnimatorKeys.strokeColor.rawValue] as? [String: Any] {
      self.strokeColor = try? KeyframeGroup<Color>(dictionary: strokeColorDictionary)
    } else {
      self.strokeColor = nil
    }
    if let strokeWidthDictionary = animatorDictionary[TextAnimatorKeys.strokeWidth.rawValue] as? [String: Any] {
      self.strokeWidth = try? KeyframeGroup<Vector1D>(dictionary: strokeWidthDictionary)
    } else {
      self.strokeWidth = nil
    }
    if let trackingDictionary = animatorDictionary[TextAnimatorKeys.tracking.rawValue] as? [String: Any] {
      self.tracking = try? KeyframeGroup<Vector1D>(dictionary: trackingDictionary)
    } else {
      self.tracking = nil
    }
    if let anchorDictionary = animatorDictionary[TextAnimatorKeys.anchor.rawValue] as? [String: Any] {
      self.anchor = try? KeyframeGroup<Vector3D>(dictionary: anchorDictionary)
    } else {
      self.anchor = nil
    }
    if let positionDictionary = animatorDictionary[TextAnimatorKeys.position.rawValue] as? [String: Any] {
      self.position = try? KeyframeGroup<Vector3D>(dictionary: positionDictionary)
    } else {
      self.position = nil
    }
    if let scaleDictionary = animatorDictionary[TextAnimatorKeys.scale.rawValue] as? [String: Any] {
      self.scale = try? KeyframeGroup<Vector3D>(dictionary: scaleDictionary)
    } else {
      self.scale = nil
    }
    if let skewDictionary = animatorDictionary[TextAnimatorKeys.skew.rawValue] as? [String: Any] {
      self.skew = try? KeyframeGroup<Vector1D>(dictionary: skewDictionary)
    } else {
      self.skew = nil
    }
    if let skewAxisDictionary = animatorDictionary[TextAnimatorKeys.skewAxis.rawValue] as? [String: Any] {
      self.skewAxis = try? KeyframeGroup<Vector1D>(dictionary: skewAxisDictionary)
    } else {
      self.skewAxis = nil
    }
    if let rotationDictionary = animatorDictionary[TextAnimatorKeys.rotation.rawValue] as? [String: Any] {
      self.rotation = try? KeyframeGroup<Vector1D>(dictionary: rotationDictionary)
    } else {
      self.rotation = nil
    }
    if let opacityDictionary = animatorDictionary[TextAnimatorKeys.opacity.rawValue] as? [String: Any] {
      self.opacity = try KeyframeGroup<Vector1D>(dictionary: opacityDictionary)
    } else {
      self.opacity = nil
    }
  }
  
}
