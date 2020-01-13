//
//  LayerTransformPropertyMap.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation
import CoreGraphics
import QuartzCore

final class LayerTransformProperties: NodePropertyMap, KeypathSearchable {
  
  init(transform: Transform) {
    
    self.anchor = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.anchorPoint.keyframes))
    self.scale = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.scale.keyframes))
    self.opacity = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.opacity.keyframes))
    
    var propertyMap: [String: AnyNodeProperty] = [
      "Anchor Point" : anchor,
      "Scale" : scale,
      "Opacity" : opacity
    ]
    
    if transform.positionX != nil || transform.positionY != nil || transform.positionZ != nil {
      self.position = nil
      self.positionX = transform.positionY.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
      self.positionY = transform.positionY.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
      self.positionZ = transform.positionZ.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
    } else if let positionKeyframes = transform.position?.keyframes {
      self.position = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframes))
      self.positionX = nil
      self.positionY = nil
      self.positionZ = nil
    } else {
      self.position = nil
      self.positionY = nil
      self.positionX = nil
      self.positionZ = nil
    }

    propertyMap["X Position"] = positionX
    propertyMap["Y Position"] = positionY
    propertyMap["Z Position"] = positionZ
    propertyMap["Position"] = position

    if transform.rotationX != nil || transform.rotationY != nil || transform.rotationZ != nil {
      self.rotation = nil
      self.rotationX = transform.rotationX.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
      self.rotationY = transform.rotationY.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
      self.rotationZ = transform.rotationZ.map { NodeProperty(provider: KeyframeInterpolator(keyframes: $0.keyframes)) }
    } else if let rotationKeyframes = transform.rotation?.keyframes {
      let rotation: NodeProperty<Vector1D> = NodeProperty(provider: KeyframeInterpolator(keyframes: rotationKeyframes))
      self.rotation = rotation
      self.rotationX = nil
      self.rotationY = nil
      self.rotationZ = nil
    } else {
      self.rotation = nil
      self.rotationX = nil
      self.rotationY = nil
      self.rotationZ = nil
    }

    propertyMap["X Rotation"] = rotationX
    propertyMap["Y Rotation"] = rotationY
    propertyMap["Z Rotation"] = rotationZ
    propertyMap["Rotation"] = rotation
    
    self.keypathProperties = propertyMap
    self.properties = Array(propertyMap.values)
  }
  
  let keypathProperties: [String : AnyNodeProperty]
  var keypathName: String = "Transform"
  
  var childKeypaths: [KeypathSearchable] {
    return []
  }
  
  let properties: [AnyNodeProperty]
  
  let anchor: NodeProperty<Vector3D>
  let scale: NodeProperty<Vector3D>
  let rotation: NodeProperty<Vector1D>?
  let rotationX: NodeProperty<Vector1D>?
  let rotationY: NodeProperty<Vector1D>?
  let rotationZ: NodeProperty<Vector1D>?
  let position: NodeProperty<Vector3D>?
  let positionX: NodeProperty<Vector1D>?
  let positionY: NodeProperty<Vector1D>?
  let positionZ: NodeProperty<Vector1D>?
  let opacity: NodeProperty<Vector1D>
  
}

class LayerTransformNode: AnimatorNode {
  let outputNode: NodeOutput = PassThroughOutputNode(parent: nil)
  
  init(transform: Transform, cameraPosition: Vector3D?) {
    self.transformProperties = LayerTransformProperties(transform: transform)
    self.cameraPosition = cameraPosition ?? Vector3D(x: 0, y: 0, z: 1777.8) // Default 50mm camera in AfterEffect
  }
  
  let transformProperties: LayerTransformProperties
  
  // MARK: Animator Node Protocol
  
  var propertyMap: NodePropertyMap & KeypathSearchable {
    return transformProperties
  }
  
  var parentNode: AnimatorNode?
  var hasLocalUpdates: Bool = false
  var hasUpstreamUpdates: Bool = false
  var lastUpdateFrame: CGFloat? = nil
  var isEnabled: Bool = true
  
  func shouldRebuildOutputs(frame: CGFloat) -> Bool {
    return hasLocalUpdates || hasUpstreamUpdates
  }
  
  func rebuildOutputs(frame: CGFloat) {
    opacity = Float(transformProperties.opacity.value.cgFloatValue) * 0.01
    
    let position: Vector3D
    if let position3DValue = transformProperties.position?.value {
      position = position3DValue
    } else {
      position = Vector3D(
        x: transformProperties.positionX?.value.value ?? 0.0,
        y: transformProperties.positionY?.value.value ?? 0.0,
        z: transformProperties.positionZ?.value.value ?? 0.0
      )
    }

    let rotation: Vector3D
    if let rotation1Dvalue = transformProperties.rotation?.value {
        rotation = Vector3D(x: 0, y: 0, z: rotation1Dvalue.value)
    } else {
      rotation = Vector3D(
        x: transformProperties.rotationX?.value.value ?? 0.0,
        y: transformProperties.rotationY?.value.value ?? 0.0,
        z: transformProperties.rotationZ?.value.value ?? 0.0
      )
    }

    localTransform = CATransform3D.makeTransform(
        cameraPosition: cameraPosition,
        anchor: transformProperties.anchor.value,
        position: position,
        scale: transformProperties.scale.value,
        rotation: rotation
    )
    
    if let parentNode = parentNode as? LayerTransformNode {
      globalTransform = CATransform3DConcat(localTransform, parentNode.globalTransform)
    } else {
      globalTransform = localTransform
    }
  }

  var cameraPosition: Vector3D
  var opacity: Float = 1
  var localTransform: CATransform3D = CATransform3DIdentity
  var globalTransform: CATransform3D = CATransform3DIdentity
  
}
