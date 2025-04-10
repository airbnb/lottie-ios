//
//  TextLayer.swift
//  Pods
//
//  Created by Brandon Withrow on 8/3/20.
//

import CoreGraphics
import CoreText
import Foundation
import QuartzCore
/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
import UIKit
#endif

// MARK: - CoreTextRenderLayer

/// A CALayer subclass that renders text content using CoreText
final class CoreTextRenderLayer: CALayer {
    
    // MARK: Public
    
    public var text: String? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var font: CTFont? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var alignment = NSTextAlignment.left {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var lineHeight: CGFloat = 0 {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var tracking: CGFloat = 0 {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var fillColor: CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var backColor: CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    
    public var strokeColor: CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var strokeWidth: CGFloat = 0 {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var showUnderLine = false {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var strokeOnTop = false {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var preferredSize: CGSize? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var start: Int? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    
    
    public var end: Int? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    
    public var textRangeColor:CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var textRangeFont:UIFont? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    /// The type of unit to use when computing the `start` / `end` range within the text string
    public var textRangeUnit: TextRangeUnit? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    /// The opacity to apply to the range between `start` and `end`
    public var selectedRangeOpacity: CGFloat? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public func sizeToFit() {
        updateTextContent()
        bounds = drawingRect
        anchorPoint = drawingAnchor
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public var attributesStr: NSAttributedString? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    // MARK: Internal
    
    override func action(forKey _: String) -> CAAction? {
        nil
    }
    
    override func draw(in ctx: CGContext) {
        guard let attributedString else { return }
        updateTextContent()
        guard fillFrameSetter != nil || strokeFrameSetter != nil else { return }
        //      self.backgroundColor = UIColor.orange.cgColor
        ctx.textMatrix = .identity
        ctx.setAllowsAntialiasing(true)
        ctx.setAllowsFontSubpixelPositioning(true)
        ctx.setAllowsFontSubpixelQuantization(true)
        ctx.setShouldAntialias(true)
        ctx.setShouldSubpixelPositionFonts(true)
        ctx.setShouldSubpixelQuantizeFonts(true)
        //内容垂直翻转
        if contentsAreFlipped() {
            ctx.translateBy(x: 0, y: drawingRect.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
        }
        
        let drawingPath = CGPath(rect: drawingRect, transform: nil)
        
        let fillFrame: CTFrame? =
        if let setter = fillFrameSetter {
            CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
        } else {
            nil
        }
        
        let strokeFrame: CTFrame? =
        if let setter = strokeFrameSetter {
            CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
        } else {
            nil
        }
        
        // This fixes a vertical padding issue that arises when drawing some fonts.
        // For some reason some fonts, such as Helvetica draw with and ascender that is greater than the one reported by CTFontGetAscender.
        // I suspect this is actually an issue with the Attributed string, but cannot reproduce.
        
        var tempFont:UIFont?
        if let rangFont = textRangeFont ,CTFontGetCapHeight(font!) < CTFontGetCapHeight(rangFont){
            tempFont = rangFont
            
        } else {
            tempFont = font
        }
        if let fillFrame {
            ctx.adjustWithLineOrigins(in: fillFrame, with: tempFont)
        } else if let strokeFrame {
            ctx.adjustWithLineOrigins(in: strokeFrame, with: tempFont)
        }
        
        
        if !strokeOnTop, let strokeFrame {
            CTFrameDraw(strokeFrame, ctx)
        }
        
        
        if strokeOnTop, let strokeFrame {
            CTFrameDraw(strokeFrame, ctx)
        }
        
        if let fillFrame {
            CTFrameDraw(fillFrame, ctx)
        }
    }
    
    // MARK: Private
    
    private var drawingRect = CGRect.zero
    private var drawingAnchor = CGPoint.zero
    private var fillFrameSetter: CTFramesetter?
    private var attributedString: NSAttributedString?
    private var strokeFrameSetter: CTFramesetter?
    private var needsContentUpdate = false
    
    /// Draws Debug colors for the font alignment.
    private func drawDebug(_ ctx: CGContext) {
        if let font {
//            let ascent = CTFontGetAscent(font)
//            let descent = CTFontGetDescent(font)
//            let capHeight = CTFontGetCapHeight(font)
//            let leading = CTFontGetLeading(font)
            
            var ascent:CGFloat
            var descent:CGFloat
            var capHeight:CGFloat
            var leading:CGFloat
            if let rangFont = textRangeFont {
                if CTFontGetCapHeight(font) < CTFontGetCapHeight(rangFont) {
                    ascent = CTFontGetAscent(rangFont)
                    descent = CTFontGetDescent(rangFont)
                    capHeight = CTFontGetCapHeight(rangFont)
                    leading = CTFontGetLeading(rangFont)
                } else {
                    descent = CTFontGetDescent(font)
                    ascent = CTFontGetAscent(font)
                    capHeight = CTFontGetCapHeight(font)
                    leading = CTFontGetLeading(font)
                }
            } else {
                descent = CTFontGetDescent(font)
                ascent = CTFontGetAscent(font)
                capHeight = CTFontGetCapHeight(font)
                leading = CTFontGetLeading(font)
            }
            
            // Ascent Red
            ctx.setFillColor(CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 0.5))
            ctx.fill(CGRect(x: 0, y: 0, width: drawingRect.width, height: ascent))
            
            // Descent Blue
            ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 0.5))
            ctx.fill(CGRect(x: 0, y: ascent, width: drawingRect.width, height: descent))
            
            // Leading Yellow
            ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 0, alpha: 0.5))
            ctx.fill(CGRect(x: 0, y: ascent + descent, width: drawingRect.width, height: leading))
            
            // Cap height Green
            ctx.setFillColor(CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 0.5))
            ctx.fill(CGRect(x: 0, y: ascent - capHeight, width: drawingRect.width, height: capHeight))
            
            if drawingRect.height - ascent + descent + leading > 0 {
                // Remainder
                ctx.setFillColor(CGColor(srgbRed: 0, green: 1, blue: 1, alpha: 0.5))
                ctx
                    .fill(CGRect(
                        x: 0,
                        y: ascent + descent + leading,
                        width: drawingRect.width,
                        height: drawingRect.height - ascent + descent + leading))
            }
        }
    }
    
    private func updateTextContent() {
        guard needsContentUpdate else { return }
        needsContentUpdate = false
        guard let font, let text, text.count > 0, fillColor != nil || strokeColor != nil else {
            drawingRect = .zero
            drawingAnchor = .zero
            attributedString = nil
            fillFrameSetter = nil
            strokeFrameSetter = nil
            return
        }
        
        
//        let ascent = CTFontGetAscent(font)
//        let descent = CTFontGetDescent(font)
//        let capHeight = CTFontGetCapHeight(font)
//        let leading = CTFontGetLeading(font)
        var ascent:CGFloat
        var descent:CGFloat
        var capHeight:CGFloat
        var leading:CGFloat
        if let rangFont = textRangeFont {
            if CTFontGetCapHeight(font) < CTFontGetCapHeight(rangFont) {
                ascent = CTFontGetAscent(rangFont)
                descent = CTFontGetDescent(rangFont)
                capHeight = CTFontGetCapHeight(rangFont)
                leading = CTFontGetLeading(rangFont)
            } else {
                descent = CTFontGetDescent(font)
                ascent = CTFontGetAscent(font)
                capHeight = CTFontGetCapHeight(font)
                leading = CTFontGetLeading(font)
            }
        } else {
            descent = CTFontGetDescent(font)
            ascent = CTFontGetAscent(font)
            capHeight = CTFontGetCapHeight(font)
            leading = CTFontGetLeading(font)
        }
        
        
        
        let minLineHeight = -(ascent + descent + leading)
        
        // Calculate line spacing
        let lineSpacing = max(CGFloat(minLineHeight) + lineHeight, CGFloat(minLineHeight))
        // Build Attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.maximumLineHeight = ascent + descent + leading
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.ligature: 0,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.kern: tracking,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ]
        
        if let fillColor {
            attributes[NSAttributedString.Key.foregroundColor] = fillColor
        }
        
        if let backCo = backColor {
            attributes[NSAttributedString.Key.backgroundColor] = backCo
        }
        
        if showUnderLine {
            attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue as AnyObject
            attributes[NSAttributedString.Key.underlineColor] = fillColor
        } else {
            attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue as AnyObject
            attributes[NSAttributedString.Key.underlineColor] = UIColor.clear
        }
        
        let attrString = NSMutableAttributedString(string: text, attributes: attributes)
        
        // Apply the text animator within between the `start` and `end` indices
//        if let selectedRangeOpacity {
        if let newStart = start , let newEnd = end , newStart >= 0 && newEnd > 0 {
            // The start and end of a text animator refer to the portions of the text
            // where that animator is applies. In the schema these can be represented
            // in absolute index value, or as percentages relative to the dynamic string length.
            var startIndex: Int
            var endIndex: Int
            
            switch textRangeUnit ?? .percentage {
            case .index:
                startIndex = start ?? 0
                endIndex = end ?? text.count
                
            case .percentage:
                let startPercentage = Double(start ?? 0) / 100
                let endPercentage = Double(end ?? 100) / 100
                
                startIndex = Int(round(Double(attrString.length) * startPercentage))
                endIndex = Int(round(Double(attrString.length) * endPercentage))
            }
            
            // Carefully cap the indices, since passing invalid indices
            // to `NSAttributedString` will crash the app.
            startIndex = startIndex.clamp(0, attrString.length)
            endIndex = endIndex.clamp(0, attrString.length)
            
            // Make sure the end index actually comes after the start index
            if endIndex < startIndex {
                swap(&startIndex, &endIndex)
            }
            
            // Apply the `selectedRangeOpacity` to the current `fillColor` if provided
            
            let selRangeColor: CGColor
            if let  rangeColor = textRangeColor {
                selRangeColor = rangeColor
            } else if let fillColor {
                if let (r, g, b) = fillColor.rgb {
                    if let newOpacity = selectedRangeOpacity {
                        selRangeColor = .rgba(r, g, b, newOpacity)
                    } else {
                        selRangeColor = .rgba(r, g, b, 1.0)
                    }
                    
                } else {
                    LottieLogger.shared.warn("Could not convert color \(fillColor) to RGB values.")
                    if let newOpacity = selectedRangeOpacity {
                        selRangeColor = .rgba(0, 0, 0, newOpacity)
                    } else {
                        selRangeColor = .rgba(0, 0, 0, 1.0)
                    }
                }
            } else {
                if let newOpacity = selectedRangeOpacity {
                    selRangeColor = .rgba(0, 0, 0, newOpacity)
                } else {
                    selRangeColor = .rgba(0, 0, 0, 1.0)
                }
            }
            
            attrString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: selRangeColor,
                range: NSRange(location: startIndex, length: endIndex - startIndex))
            if let rangeFont = textRangeFont {
                attrString.addAttribute(
                    NSAttributedString.Key.font,
                    value: rangeFont,
                    range: NSRange(location: startIndex, length: endIndex - startIndex))
            }
        }
        
        attributedString = attrString
        if fillColor != nil {
            let setter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
            fillFrameSetter = setter
        } else {
            fillFrameSetter = nil
        }
        
        
        
        if let strokeColor {
            attributes[NSAttributedString.Key.foregroundColor] = nil
            attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
            attributes[NSAttributedString.Key.strokeColor] = strokeColor
            let strokeAttributedString = NSAttributedString(string: text, attributes: attributes)
            strokeFrameSetter = CTFramesetterCreateWithAttributedString(strokeAttributedString as CFAttributedString)
        } else {
            strokeFrameSetter = nil
            strokeWidth = 0
        }
        
        guard let setter = fillFrameSetter ?? strokeFrameSetter else {
            return
        }
        
        // Calculate drawing size and anchor offset
        let textAnchor: CGPoint
        if let preferredSize {
            drawingRect = CGRect(origin: .zero, size: preferredSize)
            drawingRect.size.height += (ascent - capHeight)
            drawingRect.size.height += descent
            textAnchor = CGPoint(x: 0, y: ascent - capHeight)
        } else {
            var size = CTFramesetterSuggestFrameSizeWithConstraints(
                setter,
                CFRange(location: 0, length: attrString.length),
                nil,
                CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                nil)
            
            let textHeight = ascent + descent + leading
            // 动态计算垂直居中位置
            let verticalCenter = size.height / 2.0
            // 计算基线位置，考虑描边的影响
                var baselineAdjustment: CGFloat = 0
                if strokeColor != nil && strokeWidth > 0 {
                    // 根据描边宽度调整基线
                    baselineAdjustment = min(strokeWidth * 0.5, ascent * 0.3)
                }
                
            let textBaseline = verticalCenter + (ascent - textHeight / 2.0) - (ascent * 0.3) - baselineAdjustment
            
            switch alignment {
            case .left:
                textAnchor = CGPoint(x: size.width * 0.5, y: textBaseline)
            case .right:
                textAnchor = CGPoint(x: size.width * 0.5, y: textBaseline)
            case .center:
                textAnchor = CGPoint(x: size.width * 0.5, y: textBaseline)
            default:
                textAnchor = .zero
            }
            drawingRect = CGRect(origin: .zero, size: size)
        }
        
        // Now Calculate Anchor
        drawingAnchor = CGPoint(
            x: textAnchor.x.remap(fromLow: 0, fromHigh: drawingRect.size.width, toLow: 0, toHigh: 1),
            y: textAnchor.y.remap(fromLow: 0, fromHigh: drawingRect.size.height, toLow: 0, toHigh: 1))
        
        if fillFrameSetter != nil, strokeFrameSetter != nil {
            drawingRect.size.width += strokeWidth
            drawingRect.size.height += strokeWidth
        }
    }
    
}

extension CGContext {
    
    fileprivate func adjustWithLineOrigins(in frame: CTFrame, with font: CTFont?) {
        guard let font else { return }
        
        let count = CFArrayGetCount(CTFrameGetLines(frame))
        
        guard count > 0 else { return }
        
        var o = [CGPoint](repeating: .zero, count: 1)
        CTFrameGetLineOrigins(frame, CFRange(location: count - 1, length: 1), &o)
        
        let diff = CTFontGetDescent(font) - o[0].y
        
        print("=diff==>\(diff)\n")
        if diff > 0 {
            translateBy(x: 0, y: diff)
        }
    }
    
}
