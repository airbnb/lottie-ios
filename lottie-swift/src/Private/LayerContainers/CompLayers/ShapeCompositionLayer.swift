//
//  ShapeLayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import CoreGraphics

/**
 A CompositionLayer responsible for intializing and rendering shapes
 */
class ShapeCompositionLayer: CompositionLayer {
  
  let rootNode: AnimatorNode?
  let renderContainer: ShapeContainerLayer
  
  override var renderScale: CGFloat {
    didSet {
      renderContainer.renderScale = renderScale
    }
  }
  
  init(shapeLayer: ShapeLayerModel) {
    let results = shapeLayer.items.initializeNodeTree()
    self.renderContainer = ShapeContainerLayer()
    self.rootNode = results.rootNode
    super.init(layer: shapeLayer, size: .zero)
    contentsLayer.addSublayer(renderContainer)
    for container in results.renderContainers {
      renderContainer.insertRenderLayer(container)
    }
    rootNode?.updateTree(0, forceUpdates: true)
    self.childKeypaths.append(contentsOf: results.childrenNodes)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    rootNode?.updateTree(frame, forceUpdates: forceUpdates)
    renderContainer.markRenderUpdates(forFrame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
