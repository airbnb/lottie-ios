//
//  Transform.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

/// The animatable transform for a layer. Controls position, rotation, scale, and opacity.
final class Transform: Codable {
  
  /// The anchor point of the transform.
  let anchorPoint: KeyframeGroup<Vector3D>
  
  /// The position of the transform. This is nil if the position data was split.
  let position: KeyframeGroup<Vector3D>?
  
  /// The positionX of the transform. This is nil if the position property is set.
  let positionX: KeyframeGroup<Vector1D>?
  
  /// The positionY of the transform. This is nil if the position property is set.
  let positionY: KeyframeGroup<Vector1D>?

  /// The positionZ of the transform. This is nil if the position property is set.
  let positionZ: KeyframeGroup<Vector1D>?
  
  /// The scale of the transform
  let scale: KeyframeGroup<Vector3D>
  
  /// The rotation of the transform. Note: This is single dimensional rotation.
  let rotation: KeyframeGroup<Vector1D>?

  /// The rotationX of the transform.
  let rotationX: KeyframeGroup<Vector1D>?

  /// The rotationY of the transform.
  let rotationY: KeyframeGroup<Vector1D>?

  /// The rotationZ of the transform.
  let rotationZ: KeyframeGroup<Vector1D>?
  
  /// The opacity of the transform.
  let opacity: KeyframeGroup<Vector1D>
  
  enum CodingKeys : String, CodingKey {
    case anchorPoint = "a"
    case position = "p"
    case positionX = "px"
    case positionY = "py"
    case positionZ = "pz"
    case scale = "s"
    case rotation = "r"
    case rotationX = "rx"
    case rotationY = "ry"
    case rotationZ = "rz"
    case opacity = "o"
  }

  enum PositionCodingKeys : String, CodingKey {
    case split = "s"
    case positionX = "x"
    case positionY = "y"
    case positionZ = "z"
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
    if container.contains(.positionX) || container.contains(.positionY) || container.contains(.positionZ) {
      // Position dimensions are split into two keyframe groups
      self.positionX = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .positionX)
      self.positionY = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .positionY)
      self.positionZ = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .positionZ)
      self.position = nil
    } else if let positionKeyframes = try? container.decode(KeyframeGroup<Vector3D>.self, forKey: .position) {
      // Position dimensions are a single keyframe group.
      self.position = positionKeyframes
      self.positionX = nil
      self.positionY = nil
      self.positionZ = nil
    } else if let positionContainer = try? container.nestedContainer(keyedBy: PositionCodingKeys.self, forKey: .position) {
      /// Position keyframes are split and nested.
      self.positionX = try? positionContainer.decode(KeyframeGroup<Vector1D>.self, forKey: .positionX)
      self.positionY = try? positionContainer.decode(KeyframeGroup<Vector1D>.self, forKey: .positionY)
      self.positionZ = try? positionContainer.decode(KeyframeGroup<Vector1D>.self, forKey: .positionZ)
      self.position = nil
    } else {
      /// Default value.
      self.position = KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
      self.positionX = nil
      self.positionY = nil
      self.positionZ = nil
    }
    
    
    // Scale
    self.scale = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .scale) ?? KeyframeGroup(Vector3D(x: Double(100), y: 100, z: 100))
    
    // Rotation
    if container.contains(.rotationX) || container.contains(.rotationY) || container.contains(.rotationZ) {
      self.rotationX = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .rotationX)
      self.rotationY = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .rotationY)
      self.rotationZ = try? container.decode(KeyframeGroup<Vector1D>.self, forKey: .rotationZ)
      self.rotation = nil
    } else {
      self.rotation = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotation)
        ?? KeyframeGroup(Vector1D(0.0))
      self.rotationX = nil
      self.rotationY = nil
      self.rotationZ = nil
    }
    
    // Opacity
    self.opacity = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .opacity) ?? KeyframeGroup(Vector1D(100))
  }
}
