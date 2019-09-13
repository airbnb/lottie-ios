//
//  DropShadowEffect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 9/10/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore

class DropShadowEffect: Effect {
	
	override func apply(layer: CALayer) {
		values?.forEach({ (value) in
			switch value.name {
			case "Shadow Color":
				if let colorArray = value as? ArrayEffectValue {
					layer.shadowColor = CGColor(red: CGFloat(colorArray.value[0]), green: CGFloat(colorArray.value[1]), blue: CGFloat(colorArray.value[2]), alpha: CGFloat(colorArray.value[3]))
				}
			case "Direction":
				if let direction = value as? DoubleEffectValue {
					if let distance = values?.first(where: { $0.name == "Distance" }) as? DoubleEffectValue {
						layer.shadowOffset = NSSize(width: -cos(direction.value * .pi / 180) * distance.value, height: sin(direction.value * .pi / 180) * distance.value)
					}
				}
			case "Opacity":
				if let opacity = value as? DoubleEffectValue {
					layer.shadowOpacity = Float(opacity.value) / 255.0
				}
			case "Softness":
				if let softness = value as? DoubleEffectValue {
					layer.shadowRadius = CGFloat(softness.value) / 5.0
				}
			default:
				break
			}
		})
	}
}
