//
//  RenderNode.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/17/19.
//

import CoreGraphics
import Foundation
import QuartzCore

// MARK: - RenderNode

/// A protocol that defines a node that holds render instructions
protocol RenderNode {
  var renderer: Renderable & NodeOutput { get }
}

// MARK: - Renderable

/// A protocol that defines anything with render instructions
protocol Renderable {

  /// The last frame in which this node was updated.
  var hasUpdate: Bool { get }

  func hasRenderUpdates(_ forFrame: CGFloat) -> Bool

  /// Determines if the renderer requires a custom context for drawing.
  /// If yes the shape layer will perform a custom drawing pass.
  /// If no the shape layer will be a standard CAShapeLayer
  var shouldRenderInContext: Bool { get }

  /// Passes in the CAShapeLayer to update
  func updateShapeLayer(layer: CAShapeLayer)

  /// Asks the renderer what the renderable bounds is for the given box.
  func renderBoundsFor(_ boundingBox: CGRect) -> CGRect

  /// Opportunity for renderers to inject sublayers
  func setupSublayers(layer: CAShapeLayer)

  /// Renders the shape in a custom context
  func render(_ inContext: CGContext)
}

extension RenderNode where Self: AnimatorNode {

  var outputNode: NodeOutput {
    renderer
  }

}

extension Renderable {

  func renderBoundsFor(_ boundingBox: CGRect) -> CGRect {
    /// Optional
    boundingBox
  }

}
