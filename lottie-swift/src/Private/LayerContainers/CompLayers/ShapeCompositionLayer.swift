//
//  ShapeLayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import CoreGraphics

/**
 A CompositionLayer responsible for initializing and rendering shapes
 */
final class ShapeCompositionLayer: CompositionLayer {

    private struct AssociatedPropertiesKeys {
        static var rootNode: AnimatorNode? = nil
        static var renderContainer: ShapeContainerLayer? = nil
    }

    var rootNode: AnimatorNode? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.rootNode) as? AnimatorNode
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.rootNode,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var renderContainer: ShapeContainerLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.renderContainer) as? ShapeContainerLayer
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderContainer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(shapeLayer: ShapeLayerModel) {
        let results = shapeLayer.items.initializeNodeTree()
        super.init(layer: shapeLayer, size: .zero)
        let renderContainer = ShapeContainerLayer()
        self.renderContainer = renderContainer
        self.rootNode = results.rootNode
        contentsLayer.addSublayer(renderContainer)
        for container in results.renderContainers {
            renderContainer.insertRenderLayer(container)
        }
        rootNode?.updateTree(0, forceUpdates: true)
        self.childKeypaths.append(contentsOf: results.childrenNodes)
    }

    override init(layer: Any) {
        guard let layer = layer as? ShapeCompositionLayer else {
            fatalError("init(layer:) wrong class.")
        }
        super.init(layer: layer)
        self.rootNode = nil
        self.renderContainer = nil
    }

    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        rootNode?.updateTree(frame, forceUpdates: forceUpdates)
        renderContainer?.markRenderUpdates(forFrame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateRenderScale() {
        super.updateRenderScale()
        renderContainer?.renderScale = renderScale
    }

}
