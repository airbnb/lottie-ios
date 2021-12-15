//
//  LayerTransformPropertyMap.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation
import QuartzCore

// MARK: - LayerTransformProperties

final class LayerTransformProperties: NodePropertyMap, KeypathSearchable {

  // MARK: Lifecycle

  init(transform: Transform) {

    anchor = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.anchorPoint.keyframes))
    scale = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.scale.keyframes))
    rotation = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.rotation.keyframes))
    opacity = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.opacity.keyframes))

    var propertyMap: [String: AnyNodeProperty] = [
      "Anchor Point" : anchor,
      "Scale" : scale,
      "Rotation" : rotation,
      "Opacity" : opacity,
    ]

    if
      let positionKeyframesX = transform.positionX?.keyframes,
      let positionKeyframesY = transform.positionY?.keyframes
    {
      let xPosition: NodeProperty<Vector1D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframesX))
      let yPosition: NodeProperty<Vector1D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframesY))
      propertyMap["X Position"] = xPosition
      propertyMap["Y Position"] = yPosition
      positionX = xPosition
      positionY = yPosition
      position = nil
    } else if let positionKeyframes = transform.position?.keyframes {
      let position: NodeProperty<Vector3D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframes))
      propertyMap["Position"] = position
      self.position = position
      positionX = nil
      positionY = nil
    } else {
      position = nil
      positionY = nil
      positionX = nil
    }

    keypathProperties = propertyMap
    properties = Array(propertyMap.values)
  }

  // MARK: Internal

  let keypathProperties: [String: AnyNodeProperty]
  var keypathName: String = "Transform"

  let properties: [AnyNodeProperty]

  let anchor: NodeProperty<Vector3D>
  let scale: NodeProperty<Vector3D>
  let rotation: NodeProperty<Vector1D>
  let position: NodeProperty<Vector3D>?
  let positionX: NodeProperty<Vector1D>?
  let positionY: NodeProperty<Vector1D>?
  let opacity: NodeProperty<Vector1D>

  var childKeypaths: [KeypathSearchable] {
    []
  }
}

// MARK: - LayerTransformNode

class LayerTransformNode: AnimatorNode {

  // MARK: Lifecycle

  init(transform: Transform) {
    transformProperties = LayerTransformProperties(transform: transform)
  }

  // MARK: Internal

  let outputNode: NodeOutput = PassThroughOutputNode(parent: nil)

  let transformProperties: LayerTransformProperties

  var parentNode: AnimatorNode?
  var hasLocalUpdates: Bool = false
  var hasUpstreamUpdates: Bool = false
  var lastUpdateFrame: CGFloat? = nil
  var isEnabled: Bool = true

  var opacity: Float = 1
  var localTransform: CATransform3D = CATransform3DIdentity
  var globalTransform: CATransform3D = CATransform3DIdentity

  // MARK: Animator Node Protocol

  var propertyMap: NodePropertyMap & KeypathSearchable {
    transformProperties
  }

  func shouldRebuildOutputs(frame _: CGFloat) -> Bool {
    hasLocalUpdates || hasUpstreamUpdates
  }

  func rebuildOutputs(frame _: CGFloat) {
    opacity = Float(transformProperties.opacity.value.cgFloatValue) * 0.01

    let position: CGPoint
    if let point = transformProperties.position?.value.pointValue {
      position = point
    } else if
      let xPos = transformProperties.positionX?.value.cgFloatValue,
      let yPos = transformProperties.positionY?.value.cgFloatValue
    {
      position = CGPoint(x: xPos, y: yPos)
    } else {
      position = .zero
    }

    localTransform = CATransform3D.makeTransform(
      anchor: transformProperties.anchor.value.pointValue,
      position: position,
      scale: transformProperties.scale.value.sizeValue,
      rotation: transformProperties.rotation.value.cgFloatValue,
      skew: nil,
      skewAxis: nil)

    if let parentNode = parentNode as? LayerTransformNode {
      globalTransform = CATransform3DConcat(localTransform, parentNode.globalTransform)
    } else {
      globalTransform = localTransform
    }
  }
}
