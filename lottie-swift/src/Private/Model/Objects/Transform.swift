//
//  Transform.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

/// The animatable transform for a layer. Controls position, rotation, scale, and opacity.
final class Transform: Codable, DictionaryInitializable {
  
  /// The anchor point of the transform.
  let anchorPoint: KeyframeGroup<Vector3D>
  
  /// The position of the transform. This is nil if the position data was split.
  let position: KeyframeGroup<Vector3D>?
  
  /// The positionX of the transform. This is nil if the position property is set.
  let positionX: KeyframeGroup<Vector1D>?
  
  /// The positionY of the transform. This is nil if the position property is set.
  let positionY: KeyframeGroup<Vector1D>?
  
  /// The scale of the transform
  let scale: KeyframeGroup<Vector3D>
  
  /// The rotation of the transform. Note: This is single dimensional rotation.
  let rotation: KeyframeGroup<Vector1D>
  
  /// The opacity of the transform.
  let opacity: KeyframeGroup<Vector1D>
  
  /// Should always be nil.
  let rotationZ: KeyframeGroup<Vector1D>?
  
  enum CodingKeys : String, CodingKey {
    case anchorPoint = "a"
    case position = "p"
    case positionX = "px"
    case positionY = "py"
    case scale = "s"
    case rotation = "r"
    case rotationZ = "rz"
    case opacity = "o"
  }

  enum PositionCodingKeys : String, CodingKey {
    case split = "s"
    case positionX = "x"
    case positionY = "y"
  }
  
  
  required init(from decoder: Decoder) throws {
    /**
     This manual override of decode is required because we want to throw an error
     in the case that there is not position data.
     */
    let container = try decoder.container(keyedBy: Transform.CodingKeys.self)
    
    // AnchorPoint
    self.anchorPoint = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .anchorPoint) ?? KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
    
    // Position
    if container.contains(.positionX), container.contains(.positionY) {
      // Position dimensions are split into two keyframe groups
      self.positionX = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .positionX)
      self.positionY = try container.decode(KeyframeGroup<Vector1D>.self, forKey: .positionY)
      self.position = nil
    } else if let positionKeyframes = try? container.decode(KeyframeGroup<Vector3D>.self, forKey: .position) {
      // Position dimensions are a single keyframe group.
      self.position = positionKeyframes
      self.positionX = nil
      self.positionY = nil
    } else if let positionContainer = try? container.nestedContainer(keyedBy: PositionCodingKeys.self, forKey: .position),
      let positionX = try? positionContainer.decode(KeyframeGroup<Vector1D>.self, forKey: .positionX),
      let positionY = try? positionContainer.decode(KeyframeGroup<Vector1D>.self, forKey: .positionY) {
      /// Position keyframes are split and nested.
      self.positionX = positionX
      self.positionY = positionY
      self.position = nil
    } else {
      /// Default value.
      self.position = KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
      self.positionX = nil
      self.positionY = nil
    }
    
    
    // Scale
    self.scale = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .scale) ?? KeyframeGroup(Vector3D(x: Double(100), y: 100, z: 100))
    
    // Rotation
    if let rotationZ = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotationZ) {
      self.rotation = rotationZ
    } else {
       self.rotation = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotation) ?? KeyframeGroup(Vector1D(0))
    }
    self.rotationZ = nil
    
    // Opacity
    self.opacity = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .opacity) ?? KeyframeGroup(Vector1D(100))
  }
  
  init(dictionary: [String : Any]) throws {
    if let anchorPointDictionary = dictionary[CodingKeys.anchorPoint.rawValue] as? [String: Any],
       let anchorPoint = try? KeyframeGroup<Vector3D>(dictionary: anchorPointDictionary) {
      self.anchorPoint = anchorPoint
    } else {
      self.anchorPoint = KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
    }
    
    if let xDictionary = dictionary[CodingKeys.positionX.rawValue] as? [String: Any],
       let yDictionary = dictionary[CodingKeys.positionY.rawValue] as? [String: Any] {
      self.positionX = try KeyframeGroup<Vector1D>(dictionary: xDictionary)
      self.positionY = try KeyframeGroup<Vector1D>(dictionary: yDictionary)
      self.position = nil
    } else if let positionDictionary = dictionary[CodingKeys.position.rawValue] as? [String: Any],
              positionDictionary[KeyframeGroup<Vector3D>.KeyframeWrapperKey.keyframeData.rawValue] != nil {
      self.position = try KeyframeGroup<Vector3D>(dictionary: positionDictionary)
      self.positionX = nil
      self.positionY = nil
    } else if let positionDictionary = dictionary[CodingKeys.position.rawValue] as? [String: Any],
              let xDictionary = positionDictionary[PositionCodingKeys.positionX.rawValue] as? [String: Any],
              let yDictionary = positionDictionary[PositionCodingKeys.positionY.rawValue] as? [String: Any] {
      self.positionX = try KeyframeGroup<Vector1D>(dictionary: xDictionary)
      self.positionY = try KeyframeGroup<Vector1D>(dictionary: yDictionary)
      self.position = nil
    } else {
      self.position = KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
      self.positionX = nil
      self.positionY = nil
    }
    
    if let scaleDictionary = dictionary[CodingKeys.scale.rawValue] as? [String: Any],
       let scale = try? KeyframeGroup<Vector3D>(dictionary: scaleDictionary) {
      self.scale = scale
    } else {
      self.scale = KeyframeGroup(Vector3D(x: Double(100), y: 100, z: 100))
    }
    if let rotationDictionary = dictionary[CodingKeys.rotationZ.rawValue] as? [String: Any],
       let rotation = try? KeyframeGroup<Vector1D>(dictionary: rotationDictionary) {
      self.rotation = rotation
    } else if let rotationDictionary = dictionary[CodingKeys.rotation.rawValue] as? [String: Any],
              let rotation = try? KeyframeGroup<Vector1D>(dictionary: rotationDictionary) {
      self.rotation = rotation
    } else {
      self.rotation = KeyframeGroup(Vector1D(0))
    }
    self.rotationZ = nil
    if let opacityDictionary = dictionary[CodingKeys.opacity.rawValue] as? [String: Any],
       let opacity = try? KeyframeGroup<Vector1D>(dictionary: opacityDictionary) {
      self.opacity = opacity
    } else {
      self.opacity = KeyframeGroup(Vector1D(100))
    }
  }
}
