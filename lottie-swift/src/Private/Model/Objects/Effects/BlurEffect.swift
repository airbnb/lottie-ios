//
//  BlurEffect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 11/6/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore
#if os(iOS)
import CoreImage
#endif

class BlurEffect: Effect {
    
    private var gaussianBlurEffect: GaussianBlurEffect?
    
    override func setUp(layer: CALayer) {
        if name == "Gaussian Blur" {
            guard let shapeLayer = layer as? (CALayer & Composition) else { return }
            if gaussianBlurEffect == nil {
                gaussianBlurEffect = GaussianBlurEffect(layer: shapeLayer, effect: self)
            }
        } else {
            super.setUp(layer: layer)
        }
    }
    
    override func apply(layer: CALayer, frame: CGFloat) {
        if name == "Gaussian Blur" {
            gaussianBlurEffect?.apply(frame: frame)
        } else {
            super.apply(layer: layer, frame: frame)
        }
    }
}

class GaussianBlurEffect {
    let layer: (CALayer & Composition)
    
    let blurriness: KeyframeInterpolator<Vector1D>?
    
    init(layer: (CALayer & Composition), effect: Effect) {
        self.layer = layer
        self.blurriness = (effect.values?.first(where: { $0.name == "Blurriness" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
    }
    
    func apply(frame: CGFloat) {
        guard let blurriness = (blurriness?.value(frame: frame) as? Vector1D)?.value else {
            return
        }
        
        if #available(OSX 10.10, *) {
            layer.contentsLayer.filters = [CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": blurriness]) as Any]
        }
    }
}

class FastBlurEffect {
    let layer: (CALayer & Composition)
    
    let blurriness: KeyframeInterpolator<Vector1D>?
    
    init(layer: (CALayer & Composition), effect: Effect) {
        self.layer = layer
        self.blurriness = (effect.values?.first(where: { $0.name == "Blurriness" }) as? InterpolatableEffectValue<Vector1D>)?.interpolator
    }
    
    func apply(frame: CGFloat) {
        guard let blurriness = (blurriness?.value(frame: frame) as? Vector1D)?.value else {
            return
        }
        
        if #available(OSX 10.10, *) {
            layer.contentsLayer.filters = [CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": blurriness]) as Any]
        }
    }
}
