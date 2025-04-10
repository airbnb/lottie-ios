//
//  LayerTransformPropertyMap.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import QuartzCore

// MARK: - LayerTransformProperties

final class LayerTransformProperties: NodePropertyMap, KeypathSearchable {

  // MARK: Lifecycle

  init(transform: Transform) {
    anchor = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.anchorPoint.keyframes))
    scale = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.scale.keyframes))
    rotationX = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.rotationX.keyframes))
    rotationY = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.rotationY.keyframes))
    rotationZ = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.rotationZ.keyframes))
    opacity = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.opacity.keyframes))

    var propertyMap: [String: AnyNodeProperty] = [
      "Anchor Point": anchor,
      PropertyName.scale.rawValue: scale,
      PropertyName.rotation.rawValue: rotationZ,
      "Rotation X": rotationX,
      "Rotation Y": rotationY,
      "Rotation Z": rotationZ,
      PropertyName.opacity.rawValue: opacity,
    ]

    if
      let positionKeyframesX = transform.positionX?.keyframes,
      let positionKeyframesY = transform.positionY?.keyframes
    {
      let xPosition: NodeProperty<LottieVector1D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframesX))
      let yPosition: NodeProperty<LottieVector1D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframesY))
      propertyMap["X Position"] = xPosition
      propertyMap["Y Position"] = yPosition
      positionX = xPosition
      positionY = yPosition
      position = nil
    } else if let positionKeyframes = transform.position?.keyframes {
      let position: NodeProperty<LottieVector3D> = NodeProperty(provider: KeyframeInterpolator(keyframes: positionKeyframes))
      propertyMap[PropertyName.position.rawValue] = position
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
  var keypathName = "Transform"

  let properties: [AnyNodeProperty]

  let anchor: NodeProperty<LottieVector3D>
  let scale: NodeProperty<LottieVector3D>
  let rotationX: NodeProperty<LottieVector1D>
  let rotationY: NodeProperty<LottieVector1D>
  let rotationZ: NodeProperty<LottieVector1D>
  let position: NodeProperty<LottieVector3D>?
  let positionX: NodeProperty<LottieVector1D>?
  let positionY: NodeProperty<LottieVector1D>?
  let opacity: NodeProperty<LottieVector1D>

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
  var hasLocalUpdates = false
  var hasUpstreamUpdates = false
  var lastUpdateFrame: CGFloat? = nil
  var isEnabled = true

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

    let position: CGPoint =
      if let point = transformProperties.position?.value.pointValue {
        point
      } else if
        let xPos = transformProperties.positionX?.value.cgFloatValue,
        let yPos = transformProperties.positionY?.value.cgFloatValue
      {
        CGPoint(x: xPos, y: yPos)
      } else {
        .zero
      }

    localTransform = CATransform3D.makeTransform(
//      anchor: transformProperties.anchor.value.pointValue,\
    //这里注释上面的，是因为有的json自带a[k[1,2,3]],自动偏移导致文本框无法居中，所以这里修改不读取直接设置0
      anchor: CGPoint(x: 0, y: 0),
      position: position,
      scale: transformProperties.scale.value.sizeValue,
      rotationX: transformProperties.rotationX.value.cgFloatValue,
      rotationY: transformProperties.rotationY.value.cgFloatValue,
      rotationZ: transformProperties.rotationZ.value.cgFloatValue,
      skew: nil,
      skewAxis: nil)

    if let parentNode = parentNode as? LayerTransformNode {
      globalTransform = CATransform3DConcat(localTransform, parentNode.globalTransform)
    } else {
      globalTransform = localTransform
    }
  }
}
