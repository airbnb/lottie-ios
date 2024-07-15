//
//  PathNode.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/16/19.
//

import CoreGraphics
import Foundation

// MARK: - ShapeNodeProperties

final class ShapeNodeProperties: NodePropertyMap, KeypathSearchable {

  // MARK: Lifecycle

  init(shape: Shape) {
    keypathName = shape.name
    path = NodeProperty(provider: KeyframeInterpolator(keyframes: shape.path.keyframes))
    keypathProperties = [
      "Path" : path,
    ]
    properties = Array(keypathProperties.values)
  }

  // MARK: Internal

  var keypathName: String

  let path: NodeProperty<BezierPath>
  let keypathProperties: [String: any AnyNodeProperty]
  let properties: [any AnyNodeProperty]

}

// MARK: - ShapeNode

final class ShapeNode: AnimatorNode, PathNode {

  // MARK: Lifecycle

  init(parentNode: (any AnimatorNode)?, shape: Shape) {
    pathOutput = PathOutputNode(parent: parentNode?.outputNode)
    properties = ShapeNodeProperties(shape: shape)
    self.parentNode = parentNode
  }

  // MARK: Internal

  let properties: ShapeNodeProperties

  let pathOutput: PathOutputNode

  let parentNode: (any AnimatorNode)?
  var hasLocalUpdates = false
  var hasUpstreamUpdates = false
  var lastUpdateFrame: CGFloat? = nil

  // MARK: Animator Node
  var propertyMap: any (NodePropertyMap & KeypathSearchable) {
    properties
  }

  var isEnabled = true {
    didSet {
      pathOutput.isEnabled = isEnabled
    }
  }

  func rebuildOutputs(frame: CGFloat) {
    pathOutput.setPath(properties.path.value, updateFrame: frame)
  }

}
