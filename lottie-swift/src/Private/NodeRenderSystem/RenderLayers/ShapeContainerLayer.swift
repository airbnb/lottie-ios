//
//  ShapeContainerLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import Foundation
import QuartzCore

/**
 The base layer that holds Shapes and Shape Renderers
 */
class ShapeContainerLayer: CALayer {

    private struct AssociatedPropertiesKeys {
        static var renderLayers: [ShapeContainerLayer] = []
        static var renderScale: CGFloat = 1
    }

    private(set) var renderLayers: [ShapeContainerLayer] {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderLayers
            ) as? [ShapeContainerLayer] else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderLayers,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var renderScale: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderScale
            ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderScale,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            updateRenderScale()
        }
    }

    override init() {
        super.init()
        self.renderLayers = []
        self.renderScale = 1
        self.actions = [
            "position" : NSNull(),
            "bounds" : NSNull(),
            "anchorPoint" : NSNull(),
            "transform" : NSNull(),
            "opacity" : NSNull(),
            "hidden" : NSNull(),
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        guard let layer = layer as? ShapeContainerLayer else {
            fatalError("init(layer:) wrong class.")
        }
        super.init(layer: layer)
        self.renderLayers = []
        self.renderScale = 1
    }

    func insertRenderLayer(_ layer: ShapeContainerLayer) {
        renderLayers.append(layer)
        insertSublayer(layer, at: 0)
    }

    func markRenderUpdates(forFrame: CGFloat) {
        if self.hasRenderUpdate(forFrame: forFrame) {
            self.rebuildContents(forFrame: forFrame)
        }
        guard self.isHidden == false else { return }
        renderLayers.forEach { $0.markRenderUpdates(forFrame: forFrame) }
    }

    func hasRenderUpdate(forFrame: CGFloat) -> Bool {
        return false
    }

    func rebuildContents(forFrame: CGFloat) {
        /// Override
    }

    func updateRenderScale() {
        self.contentsScale = self.renderScale
        renderLayers.forEach( { $0.renderScale = renderScale } )
    }

}
