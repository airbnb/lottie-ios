//
//  RenderLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/18/19.
//

import Foundation
import QuartzCore

/**
 The layer responsible for rendering shape objects
 */
final class ShapeRenderLayer: ShapeContainerLayer {

    private struct AssociatedPropertiesKeys {
        static var shapeLayer: CAShapeLayer = CAShapeLayer()
        static var renderer: RenderDependency? = nil
    }

    typealias RenderDependency = Renderable & NodeOutput
    fileprivate(set) var renderer: RenderDependency {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderer
            ) as? RenderDependency else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var shapeLayer: CAShapeLayer {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.shapeLayer
            ) as? CAShapeLayer else {
                let shapeLayer = CAShapeLayer()
                self.shapeLayer = shapeLayer
                return shapeLayer
            }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.shapeLayer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(renderer: Renderable & NodeOutput) {
        super.init()
        self.renderer = renderer
        self.shapeLayer = CAShapeLayer()
        self.anchorPoint = .zero
        self.actions = [
            "position" : NSNull(),
            "bounds" : NSNull(),
            "anchorPoint" : NSNull(),
            "path" : NSNull(),
            "transform" : NSNull(),
            "opacity" : NSNull(),
            "hidden" : NSNull(),
        ]
        shapeLayer.actions = [
            "position" : NSNull(),
            "bounds" : NSNull(),
            "anchorPoint" : NSNull(),
            "path" : NSNull(),
            "fillColor" : NSNull(),
            "strokeColor" : NSNull(),
            "lineWidth" : NSNull(),
            "miterLimit" : NSNull(),
            "lineDashPhase" : NSNull(),
            "hidden" : NSNull(),
        ]
        addSublayer(shapeLayer)
    }

    override init(layer: Any) {
        guard let layer = layer as? ShapeRenderLayer else {
            fatalError("init(layer:) wrong class.")
        }
        super.init(layer: layer)
        self.renderer = layer.renderer
        self.shapeLayer = CAShapeLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hasRenderUpdate(forFrame: CGFloat) -> Bool {
        self.isHidden = !renderer.isEnabled
        guard self.isHidden == false else { return false }
        return renderer.hasRenderUpdates(forFrame)
    }

    override func rebuildContents(forFrame: CGFloat) {

        if renderer.shouldRenderInContext {
            if let newPath = renderer.outputPath {
                self.bounds = renderer.renderBoundsFor(newPath.boundingBox)
            } else {
                self.bounds = .zero
            }
            self.position = bounds.origin
            self.setNeedsDisplay()
        } else {
            shapeLayer.path = renderer.outputPath
            renderer.updateShapeLayer(layer: shapeLayer)
        }
    }

    override func draw(in ctx: CGContext) {
        if let path = renderer.outputPath {
            if !path.isEmpty {
                ctx.addPath(path)
            }
        }
        renderer.render(ctx)
    }

    override func updateRenderScale() {
        super.updateRenderScale()
        shapeLayer.contentsScale = self.renderScale
    }
}
