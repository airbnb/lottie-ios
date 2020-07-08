//
//  FillEffect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 5/29/20.
//  Copyright © 2020 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore
#if os(iOS)
import UIKit
#endif

class FillEffect: Effect {
    
    override func apply(layer: CALayer, frame: CGFloat) {
        values?.forEach({ (value) in
            switch value.name {
            case "Color":
                if let colorArray = value as? ArrayEffectValue,
                   let shapeLayer = layer as? ShapeComposition {
                    #if os(iOS)
                    let color = UIColor(red: CGFloat(colorArray.value[0]), green: CGFloat(colorArray.value[1]), blue: CGFloat(colorArray.value[2]), alpha: CGFloat(colorArray.value[3])).cgColor
                    #else
                    let color = CGColor(red: CGFloat(colorArray.value[0]), green: CGFloat(colorArray.value[1]), blue: CGFloat(colorArray.value[2]), alpha: CGFloat(colorArray.value[3]))
                    #endif
                    shapeLayer.renderContainer?.renderLayers.forEach {
                        (($0 as? ShapeRenderLayer)?.renderer as? FillRenderer)?.color = color
                        $0.renderLayers.forEach { shape in
                             ((shape as? ShapeRenderLayer)?.renderer as? FillRenderer)?.color = color
                        }
                    }
                }
            case "Opacity":
                if let opacity = value as? InterpolatableEffectValue<Vector1D>,
                   let shapeLayer = layer as? ShapeComposition {
                    let opacityValue = (opacity.interpolator.value(frame: frame) as! Vector1D).value
                    shapeLayer.renderContainer?.renderLayers.forEach {
                        (($0 as? ShapeRenderLayer)?.renderer as? FillRenderer)?.opacity = CGFloat(opacityValue)
                        $0.renderLayers.forEach { shape in
                            ((shape as? ShapeRenderLayer)?.renderer as? FillRenderer)?.opacity = CGFloat(opacityValue)
                        }
                    }
                }
            default:
                break
            }
        })
    }
}
