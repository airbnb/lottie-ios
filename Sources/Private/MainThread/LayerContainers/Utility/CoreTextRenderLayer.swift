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
    
    public var textRangeStrokeColor:CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var textRangeStrokeWidth:Double? {
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
    
    // ====== 新增：文本阴影属性 ======
    public var textShadowColor: CGColor? {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var textShadowOpacity: CGFloat = 1 {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var textShadowBlur: CGFloat = 0 {
        didSet {
            needsContentUpdate = true
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    public var textShadowOffset: CGSize = .zero {
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
        updateTextContent()
        guard let attributedString = attributedString,
              (fillFrameSetter != nil || strokeFrameSetter != nil),
              !drawingRect.isEmpty else {
            return
        }
        
        // Use the shared drawing method
        ssssssContext(ctx)
    }
    
    // MARK: Public - MTLTexture Generation
    
    /// A shared Metal device for texture generation
    private static var sharedDevice: MTLDevice? = {
        return MTLCreateSystemDefaultDevice()
    }()
    
    /// A shared command queue for Metal operations
    private static var sharedCommandQueue: MTLCommandQueue? = {
        return sharedDevice?.makeCommandQueue()
    }()
    
    /// Generates an MTLTexture representation of the text layer using the default Metal device
     /// - Parameter pixelFormat: The pixel format for the texture (default: .rgba8Unorm)
     /// - Returns: An MTLTexture containing the rendered text, or nil if generation failed
     public func generateMTLTexture(pixelFormat: MTLPixelFormat = .rgba8Unorm) -> MTLTexture? {
         guard let device = CoreTextRenderLayer.sharedDevice else {
             print("Error: No Metal device available")
             return nil
         }
         return generateMTLTexture(device: device, pixelFormat: pixelFormat)
     }
     
     /// Example of how to use the generated MTLTexture in a Metal rendering pipeline
     /// - Parameters:
     ///   - commandBuffer: The command buffer to encode rendering commands into
     ///   - renderPassDescriptor: The render pass descriptor for the current frame
     ///   - viewportSize: The size of the viewport
     /// - Returns: Whether the rendering was successful
     public func renderWithMetal(commandBuffer: MTLCommandBuffer,
                               renderPassDescriptor: MTLRenderPassDescriptor,
                               viewportSize: CGSize) -> Bool {
         // This is just an example implementation. In a real application, you would:
         // 1. Create and maintain your own Metal rendering pipeline
         // 2. Set up vertex and fragment shaders
         // 3. Configure the rendering state
         // 4. Draw the texture using appropriate coordinates
         
         guard let device = CoreTextRenderLayer.sharedDevice,
               let texture = generateMTLTexture(device: device) else {
             return false
         }
         
         // Create a render command encoder
         guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
             return false
         }
         
         // Set the viewport
         renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0,
                                              width: Double(viewportSize.width),
                                              height: Double(viewportSize.height),
                                              znear: 0.0, zfar: 1.0))
         
         // In a real implementation, you would:
         // 1. renderEncoder.setRenderPipelineState(pipelineState)
         // 2. renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
         // 3. renderEncoder.setFragmentTexture(texture, index: 0)
         // 4. renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
         
         // End encoding
         renderEncoder.endEncoding()
         
         return true
     }
    
    /// Generates an MTLTexture representation of the text layer
    /// - Parameters:
    ///   - device: The Metal device to use for creating the texture
    ///   - pixelFormat: The pixel format for the texture (default: .rgba8Unorm)
    /// - Returns: An MTLTexture containing the rendered text, or nil if generation failed
    public func generateMTLTexture(device: MTLDevice, pixelFormat: MTLPixelFormat = .rgba8Unorm) -> MTLTexture? {
        // Update text content if needed
        updateTextContent()
        
        // Ensure we have content to render
        guard let attributedString = attributedString,
              (fillFrameSetter != nil || strokeFrameSetter != nil),
              !drawingRect.isEmpty else {
            return nil
        }
        
        // Calculate the size with pixel alignment
        let scale: CGFloat = 2.0 // Use higher resolution for better quality
        let pixelWidth = Int(ceil(drawingRect.width * scale))
        let pixelHeight = Int(ceil(drawingRect.height * scale))
        
        // Ensure dimensions are valid
        guard pixelWidth > 0, pixelHeight > 0 else { return nil }
        
        // Create bitmap context for rendering
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(data: nil,
                                     width: pixelWidth,
                                     height: pixelHeight,
                                     bitsPerComponent: 8,
                                     bytesPerRow: pixelWidth * 4,
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Clear the context
        context.clear(CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        // Scale the context
        context.scaleBy(x: scale, y: scale)
        
        // Draw the text into the context
        ssssssContext(context)
        
        // Create CGImage from context
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        // Create texture descriptor
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: pixelWidth,
            height: pixelHeight,
            mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        
        // Create texture from device
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }
        
        // Create a bitmap context for the texture data
        let bytesPerRow = pixelWidth * 4
        let region = MTLRegionMake2D(0, 0, pixelWidth, pixelHeight)
        
        // Get image data
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }
        
        // Copy image data to texture
        texture.replace(region: region, mipmapLevel: 0, withBytes: bytes, bytesPerRow: bytesPerRow)
        
        return texture
    }
    
    /// Draws the text content into the provided context
    /// - Parameter ctx: The CGContext to draw into
    private func ssssssContext(_ ctx: CGContext) {
        guard let attributedString else { return }
        
        ctx.textMatrix = .identity
        ctx.setAllowsAntialiasing(true)
        ctx.setAllowsFontSubpixelPositioning(true)
        ctx.setAllowsFontSubpixelQuantization(true)
        ctx.setShouldAntialias(true)
        ctx.setShouldSubpixelPositionFonts(true)
        ctx.setShouldSubpixelQuantizeFonts(true)
        
        // Handle content flipping
        if contentsAreFlipped() {
            ctx.translateBy(x: 0, y: drawingRect.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            if strokeFrameSetter != nil, strokeWidth > 0 {
                ctx.translateBy(x: 0, y: -strokeWidth / 2)
            }
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
        
        // Font adjustment
        var tempFont: UIFont?
        if let rangFont = textRangeFont, CTFontGetCapHeight(font!) < CTFontGetCapHeight(rangFont) {
            tempFont = rangFont
        } else {
            tempFont = font
        }
        
        if let fillFrame {
            ctx.adjustWithLineOrigins(in: fillFrame, with: tempFont)
        } else if let strokeFrame {
            ctx.adjustWithLineOrigins(in: strokeFrame, with: tempFont)
        }
        
        // Draw stroke underneath if not on top
        if !strokeOnTop, let strokeFrame {
            CTFrameDraw(strokeFrame, ctx)
        }
        
        // Draw stroke on top if specified
        if strokeOnTop, let strokeFrame {
            CTFrameDraw(strokeFrame, ctx)
        }
        
        if let fillFrame {
            // Draw shadow if needed
            if shadowOpacity > 0, shadowRadius > 0, let sc = shadowColor {
                ctx.saveGState()
                let alphaColor = sc.copy(alpha: CGFloat(shadowOpacity)) ?? sc
                ctx.setShadow(offset: shadowOffset, blur: shadowRadius, color: alphaColor)
                CTFrameDraw(fillFrame, ctx)
                ctx.restoreGState()
            }
            // Draw main text
            CTFrameDraw(fillFrame, ctx)
        }
    }
    
//    override func draw(in ctx: CGContext) {
//        guard let attributedString else { return }
//        updateTextContent()
//        guard fillFrameSetter != nil || strokeFrameSetter != nil else { return }
//        //      self.backgroundColor = UIColor.orange.cgColor
//        ctx.textMatrix = .identity
//        ctx.setAllowsAntialiasing(true)
//        ctx.setAllowsFontSubpixelPositioning(true)
//        ctx.setAllowsFontSubpixelQuantization(true)
//        ctx.setShouldAntialias(true)
//        ctx.setShouldSubpixelPositionFonts(true)
//        ctx.setShouldSubpixelQuantizeFonts(true)
//        //内容垂直翻转
//        if contentsAreFlipped() {
//            ctx.translateBy(x: 0, y: drawingRect.height)
//            ctx.scaleBy(x: 1.0, y: -1.0)
//            //            // ← 在这里加
//            //            if strokeFrameSetter != nil, strokeWidth > 0 {
//            //                ctx.translateBy(x: 0, y: -strokeWidth / 2)
//            //            }
//        }
//
//        let drawingPath = CGPath(rect: drawingRect, transform: nil)
//
//        let fillFrame: CTFrame? =
//        if let setter = fillFrameSetter {
//            CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
//        } else {
//            nil
//        }
//
//        let strokeFrame: CTFrame? =
//        if let setter = strokeFrameSetter {
//            CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
//        } else {
//            nil
//        }
//
//        // This fixes a vertical padding issue that arises when drawing some fonts.
//        // For some reason some fonts, such as Helvetica draw with and ascender that is greater than the one reported by CTFontGetAscender.
//        // I suspect this is actually an issue with the Attributed string, but cannot reproduce.
//
//        var tempFont:UIFont?
//        if let rangFont = textRangeFont ,CTFontGetCapHeight(font!) < CTFontGetCapHeight(rangFont){
//            tempFont = rangFont
//
//        } else {
//            tempFont = font
//        }
//        if let fillFrame {
//            ctx.adjustWithLineOrigins(in: fillFrame, with: tempFont)
//        } else if let strokeFrame {
//            ctx.adjustWithLineOrigins(in: strokeFrame, with: tempFont)
//        }
//
//
//        if !strokeOnTop, let strokeFrame {
//            CTFrameDraw(strokeFrame, ctx)
//        }
//
//
//        if strokeOnTop, let strokeFrame {
//            CTFrameDraw(strokeFrame, ctx)
//        }
//
//        if let fillFrame {
////            // ---------- 阴影绘制 ----------
////            if shadowOpacity > 0, shadowRadius > 0, let sc = shadowColor {
////                ctx.saveGState()
////                let alphaColor = sc.copy(alpha: CGFloat(shadowOpacity)) ?? sc
////                ctx.setShadow(offset: shadowOffset, blur: shadowRadius, color: alphaColor)
////                CTFrameDraw(fillFrame, ctx)
////                ctx.restoreGState()
////            }
//            CTFrameDraw(fillFrame, ctx)
//        }
//    }
    
    // MARK: Private
    
    private var drawingRect = CGRect.zero
    private var drawingAnchor = CGPoint.zero
    private var fillFrameSetter: CTFramesetter?
    private(set) var attributedString: NSAttributedString?
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
        
        // ====== 新增：阴影富文本 ======
        if let sColor = textShadowColor {
            let nsShadow = NSShadow()
            nsShadow.shadowColor = UIColor(cgColor: sColor.copy(alpha: textShadowOpacity) ?? sColor)
            nsShadow.shadowBlurRadius = textShadowBlur
            // 根据字体基线差值自动校正阴影 Y 方向偏移，使不同字号保持一致
            var baselineShift = CGFloat(ascent - capHeight) * CGFloat(0.2)         // 随字号缩放
            var off = textShadowOffset
            // 水平补偿：anchorPoint.x 可能因对齐方式偏离 0.5
            let shiftX = (anchorPoint.x - 0.5) * bounds.width
            off.width  -= shiftX
            off.height -= baselineShift
            nsShadow.shadowOffset = off
            attributes[.shadow] = nsShadow
        }
        
        
        let attrString = NSMutableAttributedString(string: text, attributes: attributes)
        
        // Apply the text animator within between the `start` and `end` indices
        //        if let selectedRangeOpacity {
        var selectedRange: NSRange?       // 供后面描边用
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
            selectedRange = NSRange(location: startIndex, length: endIndex - startIndex)
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
                range: selectedRange!)
            if let rangeFont = textRangeFont {
                attrString.addAttribute(
                    NSAttributedString.Key.font,
                    value: rangeFont,
                    range: selectedRange!)
            }
            
            
        }
        
        
//        // ---------- ③ 为选区添加“描边”属性 ----------
//        if let sel = selectedRange, let selStrokeColor = textRangeStrokeColor {
//            attrString.addAttribute(.strokeColor, value: selStrokeColor, range: sel)
//            if let selStrokeW = textRangeStrokeWidth {
//                attrString.addAttribute(.strokeWidth, value: selStrokeW, range: sel)
//            }
//        }
        
        attributedString = attrString
        if fillColor != nil {
            let setter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
            fillFrameSetter = setter
        } else {
            fillFrameSetter = nil
        }
        
        if strokeColor != nil || textRangeStrokeColor != nil {
            
            // ① 复制填充层的 attributedString，完整保留所有局部属性
            let strokeAttr = NSMutableAttributedString(attributedString: attrString)
            
            // ② 去掉前景色，避免描边层顺带填充
            strokeAttr.removeAttribute(.foregroundColor,
                                       range: NSRange(location: 0,
                                                      length: strokeAttr.length))
            
            // ③ 清除可能已有的描边设置，保证之后的叠加不会互相干扰
            strokeAttr.removeAttribute(.strokeColor,
                                       range: NSRange(location: 0,
                                                      length: strokeAttr.length))
            strokeAttr.removeAttribute(.strokeWidth,
                                       range: NSRange(location: 0,
                                                      length: strokeAttr.length))
            
            // ④ 全局描边（如果有）
            if let globalStrokeColor = strokeColor {
                strokeAttr.addAttributes([.strokeColor: globalStrokeColor,
                                          .strokeWidth: strokeWidth],
                                         range: NSRange(location: 0,
                                                        length: strokeAttr.length))
            }
            
            // ⑤ 选区描边（覆盖全局，同步宽度）
            if let sel = selectedRange,
               let selStrokeColor = textRangeStrokeColor {
                
                strokeAttr.addAttribute(.strokeColor,
                                        value: selStrokeColor,
                                        range: sel)
                let w = textRangeStrokeWidth ?? strokeWidth
                strokeAttr.addAttribute(.strokeWidth,
                                        value: w,
                                        range: sel)
            }
            
            // ⑥ 创建 strokeFrameSetter
            strokeFrameSetter = CTFramesetterCreateWithAttributedString(
                strokeAttr as CFAttributedString)
        } else {
            strokeFrameSetter = nil
            strokeWidth = 0
        }

        
//        if let strokeColor {
//            // --------------------------------------------
//            // ① 复制填充字符串，保留区间字体 / 颜色等局部属性
//            // --------------------------------------------
//            let strokeMutable = NSMutableAttributedString(attributedString: attrString)
//
//            // --------------------------------------------
//            // ② 移除填充颜色，避免描边层出现填充
//            // --------------------------------------------
//            strokeMutable.removeAttribute(.foregroundColor,
//                                          range: NSRange(location: 0,
//                                                         length: strokeMutable.length))
//
//            // --------------------------------------------
//            // ③ 叠加描边属性（整段范围）
//            // --------------------------------------------
//            strokeMutable.addAttributes([
//                .strokeWidth : strokeWidth,
//                .strokeColor : strokeColor
//            ], range: NSRange(location: 0, length: strokeMutable.length))
//
//            // --------------------------------------------
//            // ④ 使用复制后的 attributedString 创建 framesetter
//            // --------------------------------------------
//            strokeFrameSetter = CTFramesetterCreateWithAttributedString(
//                strokeMutable as CFAttributedString)
//        } else {
//            strokeFrameSetter = nil
//            strokeWidth = 0
//        }
        
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
            // ② 额外把描边厚度算进去（上下各半个描边）
            if strokeColor != nil, strokeWidth > 0 {
                let extra = ceil(strokeWidth)        // ≥ strokeWidth/2 且按像素取整
                size.height += extra                 // 只加高度
            }
            
            let textHeight = ascent + descent + leading
            // 动态计算垂直居中位置
            let verticalCenter = size.height / 2.0
            // 计算基线位置，考虑描边的影响
            // -------- 关键修改开始 --------
            var baselineAdjustment: CGFloat = 0
            if strokeColor != nil && strokeWidth > 0 {
                baselineAdjustment = strokeWidth * 0.7   // 直接半个描边
                if ascent < 12 {
                    baselineAdjustment = strokeWidth * 0.6   // 直接半个描边
                }
            }
            
            
            let textBaseline = verticalCenter
            + (ascent - textHeight / 2.0)
            - (ascent * 0.4)             // 保留字体校准
            - baselineAdjustment         // 再减半个描边 → 向下
            print("ascent=====>\(ascent)")
            //            let textBaseline = verticalCenter + (ascent - textHeight / 2.0) - (ascent * 0.3) - baselineAdjustment
            
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
        //        drawingAnchor = CGPoint(
        //            x: textAnchor.x / drawingRect.width,
        //            y: textAnchor.y / drawingRect.height)
        if fillFrameSetter != nil, strokeFrameSetter != nil {
            // 扩大尺寸
            drawingRect.size.width += strokeWidth
            drawingRect.size.height += strokeWidth
            //            drawingAnchor.y = 0.3
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
