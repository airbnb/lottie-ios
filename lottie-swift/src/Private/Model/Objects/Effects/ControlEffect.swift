//
//  ControlEffect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/21/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore
#if os(iOS)
import CoreImage
#endif

class ControlEffect: Effect {
    
    private var evolutionEffect: DelayedEvolutionEffect?
    private var fastBlurEffect: FastBlurEffect?
    private var radialFastBlurEffect: RadialFastBlurEffect?
    private var centerVerticallyEffect: CenteredVerticallyEffect?
    
    override func setUp(layer: CALayer) {
        if name == "Evolution_(%)_In" {
            guard let textLayer = layer as? TextCompositionLayer else { return }
            if evolutionEffect == nil {
                evolutionEffect = DelayedEvolutionEffect(layer: textLayer, effect: self)
            }
        } else if name == "CC Radial Fast Blur" {
            guard let shapeLayer = layer as? ShapeCompositionLayer else { return }
            if radialFastBlurEffect == nil {
                radialFastBlurEffect = RadialFastBlurEffect(layer: shapeLayer, effect: self)
            }
        } else if name == "CC Fast Blur" || name == "Fast Blur (Legacy)" {
            guard let shapeLayer = layer as? ShapeCompositionLayer else { return }
            if fastBlurEffect == nil {
                fastBlurEffect = FastBlurEffect(layer: shapeLayer, effect: self)
            }
        } else if name == "CenteredVertically" {
            guard let textLayer = layer as? TextCompositionLayer else { return }
            if centerVerticallyEffect == nil {
                centerVerticallyEffect = CenteredVerticallyEffect(layer: textLayer)
            }
        } else {
            super.setUp(layer: layer)
        }
    }
    
    override func apply(layer: CALayer, frame: CGFloat) {
        if name == "Evolution_(%)_In" {
            evolutionEffect?.apply(frame: frame)
        } else if name == "CC Radial Fast Blur" {
            radialFastBlurEffect?.apply(frame: frame)
        } else if name == "CC Fast Blur" || name == "Fast Blur (Legacy)" {
            fastBlurEffect?.apply(frame: frame)
        } else if name == "CenteredVertically" {
            centerVerticallyEffect?.layer.textLayer.centeredVertically = true
        } else {
            super.apply(layer: layer, frame: frame)
        }
    }
}

class DelayedEvolutionEffect {
    
    let layer: TextCompositionLayer
    let value: KeyframeInterpolator<Vector1D>?
    var reverse: Bool?
    var position: KeyframeInterpolator<Vector3D>?
    var opacity: KeyframeInterpolator<Vector1D>?
    var delay: KeyframeInterpolator<Vector1D>?
    
    init(layer: TextCompositionLayer, effect: Effect) {
        self.layer = layer
        self.value = (effect.values?.first(where: { $0.name == "Slider" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
        layer.effects?.forEach {
            switch $0.name {
            case "Reverse_In":
                reverse = (($0.values?.first { $0.name == "Checkbox" }) as? BoolEffectValue)?.value
            case "Delay_In":
                delay = (($0.values?.first { $0.name == "Slider" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
            case "Position_In":
                position = (($0.values?.first { $0.name == "3D Point" }) as? InterpolatableEffectValue<Vector3D>)?.interpolator
            case "Opacity_In":
                opacity = (($0.values?.first { $0.name == "Slider" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
            default:
                break
            }
        }
    }
    
    func apply(frame: CGFloat) {
        guard let parts = (layer.textLayer as? PartedTextLayer)?.parts else { return }
        
        for (index, part) in parts.enumerated() {
            let delay = (self.delay?.value(frame: frame) as? Vector1D)?.cgFloatValue ?? 2.0
            let subFrame = frame - CGFloat(index) * delay
            let slider = (self.value?.value(frame: subFrame) as? Vector1D)?.cgFloatValue ?? 100.0
            let position = (self.position?.value(frame: subFrame) as? Vector3D)?.pointValue ?? Point3D(x: 0.0, y: 15.0, z: 0.0)
            let opacity = (self.opacity?.value(frame: subFrame) as? Vector1D)?.cgFloatValue ?? 0.0
            let fraction = 1.0 - slider / 100.0
            
            part.opacity = Float((1.0 - opacity) * fraction)
            if layer.textLayer.isGeometryFlipped {
               part.origin = CGPoint(x: position.x * (fraction - 1.0), y: position.y * (fraction - 1.0))
            } else {
               part.origin = CGPoint(x: position.x * fraction, y: -(position.y * fraction))
            }
        }
        layer.textLayer.setNeedsDisplay()
    }
}

class RadialFastBlurEffect {
    let layer: ShapeCompositionLayer
    let replicator: CAReplicatorLayer
    
    let center: KeyframeInterpolator<Vector3D>?
    var amount: KeyframeInterpolator<Vector1D>?
    var zoom: BoolEffectValue?
    
    init(layer: ShapeCompositionLayer, effect: Effect) {
        let replicator = CAReplicatorLayer()
        replicator.frame = layer.frame
        replicator.instanceCount = 5
        self.layer = layer
        self.replicator = replicator
        self.center = (effect.values?.first(where: { $0.name == "Center" }) as? InterpolatableEffectValue<Vector3D>)?.interpolator
        self.amount = (effect.values?.first(where: { $0.name == "Amount" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
        self.zoom = effect.values?.first(where: { $0.name == "Zoom" }) as? BoolEffectValue
    }
    
    func apply(frame: CGFloat) {
        guard let center = (center?.value(frame: frame) as? Vector3D)?.pointValue,
              let amount = (amount?.value(frame: frame) as? Vector1D)?.value else {
            return
        }
        
        if replicator.superlayer == nil {
            layer.superlayer?.addSublayer(replicator)
            replicator.addSublayer(layer)
        }
        
        if #available(OSX 10.10, *) {
            layer.contentsLayer.filters = [CIFilter(name: "CIZoomBlur", parameters: [kCIInputCenterKey: center.ciVector, "inputAmount": amount]) as Any,
                             CIFilter(name: "CIBoxBlur", parameters: ["inputRadius": amount / 5]) as Any]
        }
    }
}

extension Point3D {
    var ciVector: CIVector {
        CIVector(x: x, y: y, z: z)
    }
}

class CenteredVerticallyEffect {

    let layer: TextCompositionLayer
    
    init(layer: TextCompositionLayer) {
        self.layer = layer
    }
}
