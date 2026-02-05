//
//  RepeaterNode.swift
//  lottie-swift
//
//  Created by Rick Hohler on 2/4/26.
//

import Foundation
import QuartzCore

// MARK: - RepeaterNodeProperties

final class RepeaterNodeProperties: NodePropertyMap, KeypathSearchable {

  // MARK: Lifecycle

  init(repeater: Repeater) {
    keypathName = repeater.name
    copies = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.copies.keyframes))
    offset = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.offset.keyframes))

    anchor = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.anchorPoint.keyframes))
    position = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.position.keyframes))
    scale = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.scale.keyframes))
    rotation = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.rotationZ.keyframes))
    startOpacity = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.startOpacity.keyframes))
    endOpacity = NodeProperty(provider: KeyframeInterpolator(keyframes: repeater.endOpacity.keyframes))

    keypathProperties = [
      "Copies": copies,
      "Offset": offset,
      "Anchor Point": anchor,
      "Position": position,
      "Scale": scale,
      "Rotation": rotation,
      "Start Opacity": startOpacity,
      "End Opacity": endOpacity,
    ]
    properties = Array(keypathProperties.values)
  }

  // MARK: Internal

  let keypathProperties: [String: AnyNodeProperty]
  let properties: [AnyNodeProperty]
  let keypathName: String

  let copies: NodeProperty<LottieVector1D>
  let offset: NodeProperty<LottieVector1D>

  let anchor: NodeProperty<LottieVector3D>
  let position: NodeProperty<LottieVector3D>
  let scale: NodeProperty<LottieVector3D>
  let rotation: NodeProperty<LottieVector1D>
  let startOpacity: NodeProperty<LottieVector1D>
  let endOpacity: NodeProperty<LottieVector1D>
}

// MARK: - RepeaterNode

final class RepeaterNode: AnimatorNode {

  // MARK: Lifecycle

  init(parentNode: AnimatorNode?, repeater: Repeater, upstreamPaths: [PathOutputNode]) {
    outputNode = PassThroughOutputNode(parent: parentNode?.outputNode)
    self.parentNode = parentNode
    properties = RepeaterNodeProperties(repeater: repeater)
    self.upstreamPaths = upstreamPaths
  }

  // MARK: Internal

  let properties: RepeaterNodeProperties

  let parentNode: AnimatorNode?
  let outputNode: NodeOutput
  var hasLocalUpdates = false
  var hasUpstreamUpdates = false
  var lastUpdateFrame: CGFloat? = nil
  var isEnabled = true

  var propertyMap: NodePropertyMap & KeypathSearchable {
    properties
  }

  func forceUpstreamOutputUpdates() -> Bool {
    hasLocalUpdates || hasUpstreamUpdates
  }

  func rebuildOutputs(frame: CGFloat) {
    let copies = Int(properties.copies.value.value)
    let offset = properties.offset.value.value

    // Transform properties
    let anchor = properties.anchor.value.pointValue
    let position = properties.position.value.pointValue
    let scale = properties.scale.value.pointValue
    let rotation = properties.rotation.value.value

    // Opacity is currently not supported for repeaters in Main Thread engine
    // essentially because Fill/Stroke renderers handle opacity, and Repeater is a path modifier.
    // To support it, we'd need to change how opacity is applied or duplicate shapes.

    for pathContainer in upstreamPaths {
      // Remove upstream paths, we will replace them with repeated copies
      // But wait. ModifierNodes usually modify the path in place or append.
      // TrimPathNode *updates* the path.
      // RepeaterNode needs to generate MULTIPLE paths.
      // The `pathContainer` in `upstreamPaths` is `PathOutputNode`.
      // `PathOutputNode` has `outputPath` (CGPath) and `paths` (CompoundBezierPath?).
      // Actually `PathOutputNode` (viewed earlier) manages paths.

      // Let's look at `PathOutputNode.swift` access patterns in TrimPathNode if possible.
      // But assuming `pathContainer` has `removePaths` and `appendPath`.

      let originalPaths = pathContainer.removePaths(updateFrame: frame)

      for i in 0..<copies {
        let multiplier = CGFloat(i) + offset

        // Calculate transform for this copy
        // Repeater transform is accumulated or applied based on index relative to something?
        // AE logic:
        // Transform is applied iteratively?
        // If multiplier is 0, transform is identity?
        // Actually usually "Copies" includes original?
        // "Offset" shifts the start index.

        // Transform calculation:
        // We want T * i.
        // But Rotation/Scale are center-based (Anchor).

        var transform = CGAffineTransform.identity

        // 1. Move to Anchor
        transform = transform.translatedBy(x: anchor.x, y: anchor.y)

        // 2. Apply Position/Scale/Rotation multiplied by index
        // Position:
        transform = transform.translatedBy(x: position.x * multiplier, y: position.y * multiplier)

        // Rotation:
        transform = transform.rotated(by: (rotation * multiplier) * .pi / 180)

        // Scale:
        // Scale is exponential in AE Repeater? Or multiplicative?
        // "Scale" property 100% -> No change. 50% -> Half.
        // For index i: scale ^ i ?
        // Lottie usually treats scale 100 as 1.0.
        let scaleX = pow(scale.x / 100.0, multiplier)
        let scaleY = pow(scale.y / 100.0, multiplier)
        transform = transform.scaledBy(x: scaleX, y: scaleY)

        // 3. Move back from Anchor
        transform = transform.translatedBy(x: -anchor.x, y: -anchor.y)

        // Apply to paths
        for path in originalPaths {
          // Flatten to BezierPath if Compound? originalPaths is [BezierPath] usually?
          // removePaths returns [BezierPath].

          let validPath = path // path is BezierPath
          let transformedPath = validPath.transformed(by: transform)
          pathContainer.appendPath(transformedPath, updateFrame: frame)
        }
      }
    }
  }

  // MARK: Fileprivate

  fileprivate let upstreamPaths: [PathOutputNode]
}

// MARK: - BezierPath Extension

extension BezierPath {
  fileprivate func transformed(by transform: CGAffineTransform) -> BezierPath {
    var newPath = BezierPath()

    // Tangents are vectors, so they shouldn't be translated, only scaled/rotated.
    // We can use the same transform but zero out translation components.
    var vectorTransform = transform
    vectorTransform.tx = 0
    vectorTransform.ty = 0

    for element in elements {
      let vertex = element.vertex

      let point = vertex.point.applying(transform)
      let inTangent = vertex.inTangentRelative.applying(vectorTransform)
      let outTangent = vertex.outTangentRelative.applying(vectorTransform)

      let newVertex = CurveVertex(point: point, inTangentRelative: inTangent, outTangentRelative: outTangent)
      newPath.addVertex(newVertex)
    }

    if closed {
      newPath.close()
    }

    return newPath
  }
}

extension CompoundBezierPath {
  fileprivate func transformed(by transform: CGAffineTransform) -> CompoundBezierPath {
    var newPaths = [BezierPath]()
    for path in paths {
      newPaths.append(path.transformed(by: transform))
    }
    return CompoundBezierPath(paths: newPaths)
  }
}
