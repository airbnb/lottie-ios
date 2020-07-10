//
//  SolidCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import QuartzCore

final class SolidCompositionLayer: CompositionLayer {

    private struct AssociatedPropertiesKeys {
        static var colorProperty: NodeProperty<Color>? = nil
        static var solidShape: CAShapeLayer = CAShapeLayer()
    }

    var colorProperty: NodeProperty<Color>? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.colorProperty) as? NodeProperty<Color>
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.colorProperty,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var solidShape: CAShapeLayer {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.solidShape
            ) as? CAShapeLayer else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.solidShape,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(solid: SolidLayerModel) {
        let components = solid.colorHex.hexColorComponents()

        super.init(layer: solid, size: .zero)
        self.solidShape = CAShapeLayer()
        self.colorProperty = NodeProperty(provider: SingleValueProvider(Color(r: Double(components.red), g: Double(components.green), b: Double(components.blue), a: 1)))
        solidShape.path = CGPath(rect: CGRect(x: 0, y: 0, width: solid.width, height: solid.height), transform: nil)
        contentsLayer.addSublayer(solidShape)
    }

    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? SolidCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        super.init(layer: layer)
        self.solidShape = CAShapeLayer()
        self.colorProperty = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        guard let colorProperty = colorProperty else { return }
        colorProperty.update(frame: frame)
        solidShape.fillColor = colorProperty.value.cgColorValue
    }

    override var keypathProperties: [String : AnyNodeProperty] {
        guard let colorProperty = colorProperty else { return super.keypathProperties }
        return ["Color" : colorProperty]
    }
}
