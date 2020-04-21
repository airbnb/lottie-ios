//
//  PartedTextLayer.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/20/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import QuartzCore
import CoreGraphics

class TextLayerPart {
    var origin: CGPoint = .zero
    var opacity: Float = 0.0
}

protocol PartedTextLayer {
    var parts: [TextLayerPart]? { get }
}

class WordAnimatedTextLayer : DisabledTextLayer, PartedTextLayer {
    private var attributedString: NSAttributedString?
    override var string: Any? {
        set {
            let newAttributedString = newValue as? NSAttributedString
            if attributedString != newAttributedString {
                attributedString = newAttributedString
                updateLayers()
            }
        }
        get {
            return attributedString
        }
    }
    
    class WordPart: TextLayerPart {
        override var origin: CGPoint {
            get {
                layer.frame.origin
            }
            set {
                layer.frame.origin = newValue
            }
        }
        override var opacity: Float {
            get {
                layer.opacity
            }
            set {
                layer.opacity = newValue
            }
        }
        var layer: CALayer
        
        init(_ layer: CALayer) {
            self.layer = layer
        }
    }
    
    let shifted: Bool
    var parts: [TextLayerPart]?
    
    init(_ shifted: Bool = false) {
        self.shifted = shifted
        super.init()
    }
    
    required init?(coder: NSCoder) {
        shifted = false
        super.init(coder: coder)
    }
    
    func updateLayers() {
        guard let attributedString = attributedString else { return }
        
        sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let ranges = attributedString.words()
        parts = []
        
        ranges.forEach {
            guard let mutableString = attributedString.mutableCopy() as? NSMutableAttributedString else { return }
            
            #if os(macOS)
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:$0.0)
            mutableString.addAttribute(.foregroundColor, value: NSColor.clear, range:$0.1)
            #else
            mutableString.addAttribute(.foregroundColor, value: UIColor.clear, range:$0.0)
            mutableString.addAttribute(.foregroundColor, value: UIColor.clear, range:$0.1)
            #endif
            
            let layer = DisabledTextLayer()
            layer.frame = CGRect(origin: .zero, size: self.frame.size)
            layer.opacity = self.opacity
            layer.contentsScale = self.contentsScale
            layer.rasterizationScale = self.rasterizationScale
            layer.alignmentMode = self.alignmentMode
            layer.centeredVertically = self.centeredVertically
            
            layer.string = mutableString
            
            self.addSublayer(layer)
            parts?.append(WordPart(layer))
        }
    }
    
    override func draw(in ctx: CGContext) {}
}

class LineAnimatedTextLayer : DisabledTextLayer, PartedTextLayer {
    private var attributedString: NSAttributedString?
    
    private var lines: [CTLine]?
    private var origins: [CGPoint]?
    private(set) var parts: [TextLayerPart]?
    private lazy var clipLayer: CALayer? = { self.clipLayer(from: self) }()
        
    override var string: Any? {
        set {
            let newAttributedString = newValue as? NSAttributedString
            if attributedString != newAttributedString {
                attributedString = newAttributedString
                
                if let attributedString = newAttributedString {
                    parts = []
                    let path = CGPath(rect: self.frame, transform: nil)
                    let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString)
                    let frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, nil)
                    if let linesNS = CTFrameGetLines(frameRef) as? [CTLine] {
                        lines = linesNS
                        var origins = [CGPoint](repeating: .zero, count: linesNS.count)
                        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), &origins)
                        self.origins = origins
                        for _ in 0...linesNS.count {
                            parts?.append(TextLayerPart())
                        }
                    }
                }
            }
        }
        get {
            return attributedString
        }
    }
        
    override init() {
        super.init()
        self.isGeometryFlipped = true
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(in ctx: CGContext) {
        guard let lines = lines, let parts = parts else { return }
        var visibleFrame = bounds
        if let clipLayer = self.clipLayer {
            visibleFrame = convert(clipLayer.bounds, from: clipLayer)
        }
        
        ctx.textMatrix = .identity
        lines.enumerated().forEach { index, line in
            let part = parts[index]
            var position = origins?[index] ?? .zero
            position.x += part.origin.x
            position.y += part.origin.y
            
            if visibleFrame.contains(position) {
                ctx.setAlpha(CGFloat(part.opacity))
                ctx.textPosition = position
            
                CTLineDraw(line, ctx)
            }
        }
    }
    
    func clipLayer(from layer: CALayer?) -> CALayer? {
        if layer?.superlayer?.name?.hasSuffix("ClipView") == true {
            return layer?.superlayer
        }
        
        guard let superlayer = layer?.superlayer else { return nil }
        return clipLayer(from: superlayer)
    }
}

extension NSAttributedString {
    
    func words() -> [(NSRange, NSRange)] {
        string.split(separator: " ").map { (NSRange(..<$0.startIndex, in: string), NSRange($0.endIndex..., in: string)) }
    }
}
