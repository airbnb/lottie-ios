//
//  TransformItem.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

/// An item that define an ellipse shape
class ShapeTransform: ShapeItem, Transformable {
    
  let anchorPoint: KeyframeGroup<Vector3D>
    
  let positionX: KeyframeGroup<Vector1D>? = nil
    
  let positionY: KeyframeGroup<Vector1D>? = nil
     
  let rotationZ: KeyframeGroup<Vector1D>
  let rotationX: KeyframeGroup<Vector1D>
  let rotationY: KeyframeGroup<Vector1D>
  
  /// Position
  let position: KeyframeGroup<Vector3D>?
  
  /// Scale
  let scale: KeyframeGroup<Vector3D>
  
  /// opacity
  let opacity: KeyframeGroup<Vector1D>
    
  let orientation: KeyframeGroup<Vector3D>
  
  /// Skew
  let skew: KeyframeGroup<Vector1D>
  
  /// Skew Axis
  let skewAxis: KeyframeGroup<Vector1D>
  
  private enum CodingKeys : String, CodingKey {
    case anchorPoint = "a"
    case position = "p"
    case scale = "s"
    case rotation = "r"
    case rotationX = "rx"
    case rotationY = "ry"
    case rotationZ = "rz"
    case opacity = "o"
    case skew = "sk"
    case skewAxis = "sa"
    case orientation = "or"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeTransform.CodingKeys.self)
    self.anchorPoint = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .anchorPoint)?.flipLast() ?? KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
    self.position = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .position)?.flipLast() ?? KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
    self.scale = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .scale) ?? KeyframeGroup(Vector3D(x: Double(100), y: 100, z: 100))
    let rotationZ = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotationZ)
    self.rotationZ = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotation) ?? rotationZ ?? KeyframeGroup(Vector1D(0))
    self.rotationX = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotationX) ?? KeyframeGroup(Vector1D(0))
    self.rotationY = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .rotationY) ?? KeyframeGroup(Vector1D(0))
    self.opacity = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .opacity) ?? KeyframeGroup(Vector1D(100))
    self.skew = try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .skew) ?? KeyframeGroup(Vector1D(0))
    self.skewAxis =  try container.decodeIfPresent(KeyframeGroup<Vector1D>.self, forKey: .skewAxis) ?? KeyframeGroup(Vector1D(0))
    self.orientation = try container.decodeIfPresent(KeyframeGroup<Vector3D>.self, forKey: .orientation) ?? KeyframeGroup(Vector3D(x: Double(0), y: 0, z: 0))
    try super.init(from: decoder)
  }
  
  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(anchorPoint, forKey: .anchorPoint)
    try container.encode(position, forKey: .position)
    try container.encode(scale, forKey: .scale)
    try container.encode(rotationX, forKey: .rotationX)
    try container.encode(rotationZ, forKey: .rotationZ)
    try container.encode(rotationY, forKey: .rotationY)
    try container.encode(opacity, forKey: .opacity)
    try container.encode(skew, forKey: .skew)
    try container.encode(skewAxis, forKey: .skewAxis)
    try container.encode(orientation, forKey: .orientation)
  }
  
}
