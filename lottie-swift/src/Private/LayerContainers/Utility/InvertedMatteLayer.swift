//
//  InvertedMatteLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/28/19.
//

import Foundation
import QuartzCore

/**
 A layer that inverses the alpha output of its input layer.
 
 WARNING: This is experimental and probably not very performant.
 */
final class InvertedMatteLayer: CALayer, CompositionLayerDelegate {

    private struct AssociatedPropertiesKeys {
        static var inputMatte: CompositionLayer? = nil
        static var wrapperLayer: CALayer = CALayer()
    }

    var inputMatte: CompositionLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.inputMatte) as? CompositionLayer
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.inputMatte,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var wrapperLayer: CALayer {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.wrapperLayer
            ) as? CALayer else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.wrapperLayer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(inputMatte: CompositionLayer) {
        super.init()
        self.wrapperLayer = CALayer()
        self.inputMatte = inputMatte
        inputMatte.layerDelegate = self
        self.anchorPoint = .zero
        self.bounds = inputMatte.bounds
        self.setNeedsDisplay()
    }

    override init(layer: Any) {
        guard let layer = layer as? InvertedMatteLayer else {
            fatalError("init(layer:) wrong class.")
        }
        super.init(layer: layer)
        self.inputMatte = nil
        self.wrapperLayer = CALayer()
    }

    func frameUpdated(frame: CGFloat) {
        self.setNeedsDisplay()
        self.displayIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let inputMatte = inputMatte else { return }
        guard let fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 0, 0, 1])
            else { return }
        ctx.setFillColor(fillColor)
        ctx.fill(bounds)
        ctx.setBlendMode(.destinationOut)
        inputMatte.render(in: ctx)
    }
}
