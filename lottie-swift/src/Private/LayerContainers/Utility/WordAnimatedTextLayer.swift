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
    
    private var attributedString: NSAttributedString?
    override var string: Any? {
        set {
            if attributedString == nil {
                attributedString = newValue as? NSAttributedString
                updateLayers()
            } else {
                attributedString = newValue as? NSAttributedString
            }
        }
        get {
            return attributedString
        }
    }
    
    let shifted: Bool
    let basedOn: Selector.BasedOn
    
    init(_ shifted: Bool = false, basedOn: Selector.BasedOn?) {
        self.shifted = shifted
        self.basedOn = basedOn ?? .words
        super.init()
    }
    
    required init?(coder: NSCoder) {
        shifted = false
        basedOn = .words
        super.init(coder: coder)
    }
    
    func updateLayers() {
        guard let attributedString = attributedString else { return }
        
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let ranges = basedOn == .words ? attributedString.words() : attributedString.lines(with: bounds.width)
        
        ranges.forEach {
            guard let mutableString = attributedString.mutableCopy() as? NSMutableAttributedString else { return }
            
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:$0.0)
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:$0.1)
            
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

extension NSAttributedString {

    func lines(with width: CGFloat) -> [(NSRange, NSRange)] {
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)), transform: nil)
        let frameSetterRef = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, nil)
        let linesNS = CTFrameGetLines(frameRef)

        guard let lines = linesNS as? [CTLine] else { return [] }
        return lines.map(CTLineGetStringRange).map { (NSRange(location: 0, length: $0.location), NSRange(location: $0.location + $0.length, length: string.count - $0.location - $0.length)) }
    }
    
    func words() -> [(NSRange, NSRange)] {
        string.split(separator: " ").map { (NSRange(..<$0.startIndex, in: string), NSRange($0.endIndex..., in: string)) }
    }
}
