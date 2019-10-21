//
//  ControlEffect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/21/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation

import QuartzCore

class ControlEffect: Effect {
    
    var evolutionEffect: DelayedEvolutionEffect?
    
    override func setUp(layer: CALayer) {
        if name == "Evolution_(%)_In" {
            guard let textLayer = layer as? TextCompositionLayer else { return }
            if evolutionEffect == nil {
                evolutionEffect = DelayedEvolutionEffect(layer: textLayer, effect: self)
            }
        }
    }
    
    override func apply(layer: CALayer, frame: CGFloat) {
        if name == "Evolution_(%)_In" {
            evolutionEffect?.apply(frame: frame)
        }
    }
}

class DelayedEvolutionEffect {
    
    var layer: TextCompositionLayer
    var value: KeyframeInterpolator<Vector1D>?
    var reverse: Bool?
    var position: KeyframeInterpolator<Vector3D>?
    var opacity: KeyframeInterpolator<Vector1D>?
    var delay: KeyframeInterpolator<Vector1D>?
    
    init(layer: TextCompositionLayer, effect: Effect) {
        self.layer = layer
        self.value = (effect.values?.first(where: { $0.name == "Slider" }) as? VolumeEffectValue<Vector1D>)?.interpolator
        layer.effects?.forEach {
            switch $0.name {
            case "Reverse_In":
                reverse = (($0.values?.first { $0.name == "Checkbox" }) as? BoolEffectValue)?.value
            case "Delay_In":
                delay = (($0.values?.first { $0.name == "Slider" }) as? VolumeEffectValue<Vector1D>)?.interpolator
            case "Position_In":
                position = (($0.values?.first { $0.name == "3D Point" }) as? VolumeEffectValue<Vector3D>)?.interpolator
            case "Opacity_In":
                opacity = (($0.values?.first { $0.name == "Slider" }) as? VolumeEffectValue<Vector1D>)?.interpolator
            default:
                break
            }
        }
    }
    
    func apply(frame: CGFloat) {
        layer.textLayer.sublayers?.enumerated().forEach { index, sublayer in
            let delay = (self.delay?.value(frame: frame) as? Vector1D)?.cgFloatValue ?? 2.0
            let subFrame = frame - CGFloat(index) * delay
            let slider = (self.value?.value(frame: subFrame) as? Vector1D)?.cgFloatValue ?? 100.0
            let position = (self.position?.value(frame: subFrame) as? Vector3D)?.pointValue ?? CGPoint(x:0.0, y:15.0)
            let opacity = (self.opacity?.value(frame: subFrame) as? Vector1D)?.cgFloatValue ?? 0.0
            let fraction = 1.0 - slider / 100.0
            
            sublayer.opacity = Float((1.0 - opacity) * fraction)
            sublayer.frame.origin = CGPoint(x: position.x * fraction, y: -(position.y * fraction))
        }
    }
}
