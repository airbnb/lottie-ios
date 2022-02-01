//
//  GroupNode.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/18/19.
//

import CoreGraphics
import Foundation
import QuartzCore

// MARK: - GroupNodeProperties

final class GroupNodeProperties: NodePropertyMap, KeypathSearchable {

  // MARK: Lifecycle

  init(transform: ShapeTransform?) {
    if let transform = transform {
      anchor = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.anchor.keyframes))
      position = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.position.keyframes))
      scale = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.scale.keyframes))
      rotation = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.rotation.keyframes))
      opacity = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.opacity.keyframes))
      skew = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.skew.keyframes))
      skewAxis = NodeProperty(provider: KeyframeInterpolator(keyframes: transform.skewAxis.keyframes))
    } else {
      /// Transform node missing. Default to empty transform.
      anchor = NodeProperty(provider: SingleValueProvider(Vector3D(x: CGFloat(0), y: CGFloat(0), z: CGFloat(0))))
      position = NodeProperty(provider: SingleValueProvider(Vector3D(x: CGFloat(0), y: CGFloat(0), z: CGFloat(0))))
      scale = NodeProperty(provider: SingleValueProvider(Vector3D(x: CGFloat(100), y: CGFloat(100), z: CGFloat(100))))
      rotation = NodeProperty(provider: SingleValueProvider(Vector1D(0)))
      opacity = NodeProperty(provider: SingleValueProvider(Vector1D(100)))
      skew = NodeProperty(provider: SingleValueProvider(Vector1D(0)))
      skewAxis = NodeProperty(provider: SingleValueProvider(Vector1D(0)))
    }
    keypathProperties = [
      "Anchor Point" : anchor,
      "Position" : position,
      "Scale" : scale,
      "Rotation" : rotation,
      "Opacity" : opacity,
      "Skew" : skew,
      "Skew Axis" : skewAxis,
    ]
    properties = Array(keypathProperties.values)
  }

  // MARK: Internal

  var keypathName: String = "Transform"

  var childKeypaths: [KeypathSearchable] = []

  let keypathProperties: [String: AnyNodeProperty]
  let properties: [AnyNodeProperty]

  let anchor: NodeProperty<Vector3D>
  let position: NodeProperty<Vector3D>
  let scale: NodeProperty<Vector3D>
  let rotation: NodeProperty<Vector1D>
  let opacity: NodeProperty<Vector1D>
  let skew: NodeProperty<Vector1D>
  let skewAxis: NodeProperty<Vector1D>

  var caTransform: CATransform3D {
    CATransform3D.makeTransform(
      anchor: anchor.value.pointValue,
      position: position.value.pointValue,
      scale: scale.value.sizeValue,
      rotation: rotation.value.cgFloatValue,
      skew: skew.value.cgFloatValue,
      skewAxis: skewAxis.value.cgFloatValue)
  }
}

// MARK: - GroupNode

final class GroupNode: AnimatorNode {

  // MARK: Lifecycle

  // MARK: Initializer
  init(name: String, parentNode: AnimatorNode?, tree: NodeTree) {
    self.parentNode = parentNode
    keypathName = name
    rootNode = tree.rootNode
    properties = GroupNodeProperties(transform: tree.transform)
    groupOutput = GroupOutputNode(parent: parentNode?.outputNode, rootNode: rootNode?.outputNode)
    var childKeypaths: [KeypathSearchable] = tree.childrenNodes
    childKeypaths.append(properties)
    self.childKeypaths = childKeypaths

    for childContainer in tree.renderContainers {
      container.insertRenderLayer(childContainer)
    }
  }

  // MARK: Internal

  // MARK: Properties
  let groupOutput: GroupOutputNode

  let properties: GroupNodeProperties

  let rootNode: AnimatorNode?

  var container = ShapeContainerLayer()

  // MARK: Keypath Searchable

  let keypathName: String

  let childKeypaths: [KeypathSearchable]

  let parentNode: AnimatorNode?
  var hasLocalUpdates: Bool = false
  var hasUpstreamUpdates: Bool = false
  var lastUpdateFrame: CGFloat? = nil

  var keypathLayer: CALayer? {
    container
  }

  // MARK: Animator Node Protocol

  var propertyMap: NodePropertyMap & KeypathSearchable {
    properties
  }

  var outputNode: NodeOutput {
    groupOutput
  }

  var isEnabled: Bool = true {
    didSet {
      container.isHidden = !isEnabled
    }
  }

  func performAdditionalLocalUpdates(frame: CGFloat, forceLocalUpdate: Bool) -> Bool {
    rootNode?.updateContents(frame, forceLocalUpdate: forceLocalUpdate) ?? false
  }

  func performAdditionalOutputUpdates(_ frame: CGFloat, forceOutputUpdate: Bool) {
    rootNode?.updateOutputs(frame, forceOutputUpdate: forceOutputUpdate)
  }

  func rebuildOutputs(frame: CGFloat) {
    container.opacity = Float(properties.opacity.value.cgFloatValue) * 0.01
    container.transform = properties.caTransform
    groupOutput.setTransform(container.transform, forFrame: frame)
  }

}
