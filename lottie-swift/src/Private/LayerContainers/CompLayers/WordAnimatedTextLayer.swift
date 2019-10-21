//
//  WordAnimatedTextLayer.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/20/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Cocoa
import QuartzCore
import CoreGraphics

class WordAnimatedTextLayer : DisabledTextLayer {
    
    var attributedString: NSAttributedString?
    override var string: Any? {
        set {
            attributedString = newValue as? NSAttributedString
            updateLayers()
        }
        get {
            return attributedString
        }
    }
    
    func updateLayers() {
        guard let attributedString = attributedString else { return }
        
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let string = attributedString.string
        string.split(separator: " ").forEach {
            guard let mutableString = attributedString.mutableCopy() as? NSMutableAttributedString else { return }
            
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:NSRange(..<$0.startIndex, in: string))
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:NSRange($0.endIndex..., in: string))
            
            let layer = DisabledTextLayer()
            layer.frame = CGRect(origin: .zero, size: self.frame.size)
            layer.opacity = self.opacity
            layer.contentsScale = self.contentsScale
            layer.rasterizationScale = self.rasterizationScale
            layer.alignmentMode = self.alignmentMode
            
            layer.string = mutableString
            
            self.addSublayer(layer)
        }
    }
    
    override func draw(in ctx: CGContext) {}
}
