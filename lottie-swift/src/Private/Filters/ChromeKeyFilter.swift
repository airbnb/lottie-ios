//
//  ChromeKeyFilter.swift
//  Lottie
//
//  Created by Viktor Radulov on 12/20/20.
//  Copyright © 2020 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore
import CoreImage

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

class ChromeKeyFilter: CIFilter {
    
    class func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter? {
        let size = 16
        var cubeRGB = [Float]()

        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)

                    let color = HSBColor.create(red: red, green: green, blue: blue, alpha: 1.0)
// TODO: Separate chromaKey and brightness filter
// and add parsing Color effects parameters
//                    let alpha: CGFloat = ((color.saturation == 1 || color.saturation == 0)
//                                            && color.brightness != 1
//                                            && color.hue >= fromHue
//                                            && color.hue <= toHue) ? 0 : 1
                    let alpha = color.brightness
                    cubeRGB.append(Float(red))
                    cubeRGB.append(Float(green))
                    cubeRGB.append(Float(blue))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        let data = Data(bytes: cubeRGB, count: cubeRGB.count * MemoryLayout<Float>.size)
        let chromaKeyFilter = CIFilter(name: "CIColorCube")
        chromaKeyFilter?.setValue(NSNumber(value: size), forKey: "inputCubeDimension")
        chromaKeyFilter?.setValue(data, forKey: "inputCubeData")
        
        return chromaKeyFilter
    }
}

public struct HSBColor {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    static func create(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> HSBColor {
        #if os(iOS) || os(tvOS)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).hsbColor
        #else
        return NSColor(red: red, green: green, blue: blue, alpha: alpha).hsbColor
        #endif
    }
}

#if os(iOS) || os(tvOS)
extension UIColor {
    var hsbColor: HSBColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBColor(hue: h, saturation: s, brightness: b, alpha: a)
    }
}
#else
extension NSColor {
    var hsbColor: HSBColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBColor(hue: h, saturation: s, brightness: b, alpha: a)
    }
}
#endif
