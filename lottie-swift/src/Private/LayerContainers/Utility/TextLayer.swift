//
//  TextLayer.swift
//  Pods
//
//  Created by Brandon Withrow on 8/3/20.
//

import Foundation
import CoreText
import QuartzCore
import CoreGraphics
/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
import UIKit
#endif

final class TextLayer: CALayer {
  
  public var text: String? {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var font: CTFont? {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var alignment: NSTextAlignment = .left {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var lineHeight: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var tracking: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var fillColor: CGColor? {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var strokeColor: CGColor? {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var strokeWidth: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var strokeOnTop: Bool = false {
    didSet {
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var preferredSize: CGSize? {
    didSet {
      needsContentUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public func sizeToFit() {
    updateTextContent()
    bounds = drawingRect
    anchorPoint = drawingAnchor
    self.setNeedsLayout()
    self.setNeedsDisplay()
  }
  
  override func action(forKey event: String) -> CAAction? {
    return nil
  }
  
  override func draw(in ctx: CGContext) {
    guard let attributedString = attributedString else { return }
    updateTextContent()
    guard let setter = fillFrameSetter else { return }
    
    ctx.textMatrix = .identity
    ctx.setAllowsAntialiasing(true)
    ctx.setAllowsFontSmoothing(true)
    ctx.setAllowsFontSubpixelPositioning(true)
    ctx.setAllowsFontSubpixelQuantization(true)

    ctx.setShouldAntialias(true)
    ctx.setShouldSmoothFonts(true)
    ctx.setShouldSubpixelPositionFonts(true)
    ctx.setShouldSubpixelQuantizeFonts(true)

    ctx.translateBy(x: 0, y: drawingRect.height)
    ctx.scaleBy(x: 1.0, y: -1.0)
    
    let drawingPath = CGPath(rect: drawingRect, transform: nil)
    
    if !strokeOnTop, let strokeSetter = strokeFrameSetter {
      // Draw stroke first
      let frame = CTFramesetterCreateFrame(strokeSetter, CFRangeMake(0, attributedString.length), drawingPath, nil)
      CTFrameDraw(frame, ctx)
    }
    
    let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
    CTFrameDraw(frame, ctx)
    
    if strokeOnTop, let strokeSetter = strokeFrameSetter {
      ctx.translateBy(x: strokeWidth * -0.5, y: strokeWidth * 0.5)
      let frame = CTFramesetterCreateFrame(strokeSetter, CFRangeMake(0, attributedString.length), drawingPath, nil)
      CTFrameDraw(frame, ctx)
    }
  }
  
  private var drawingRect: CGRect = .zero
  private var drawingAnchor: CGPoint = .zero
  private var fillFrameSetter: CTFramesetter?
  private var attributedString: NSAttributedString?
  private var strokeFrameSetter: CTFramesetter?
  private var needsContentUpdate: Bool = false
  
  private func updateTextContent() {
    guard needsContentUpdate else { return }
    needsContentUpdate = false
    guard let font = font, let text = text, text.count > 0, let fillColor = fillColor else {
      drawingRect = .zero
      drawingAnchor = .zero
      attributedString = nil
      fillFrameSetter = nil
      strokeFrameSetter = nil
      return
    }

    // Get Font properties
    let ascent = CTFontGetAscent(font)
    let descent = CTFontGetDescent(font)
    let capHeight = CTFontGetCapHeight(font)
    let leading = floor(max(CTFontGetLeading(font), 0) + 0.5)
    let fontLineHeight = floor(ascent + 0.5) + floor(descent + 0.5) + leading
    let ascenderDelta = leading > 0 ? 0 : floor (0.2 * fontLineHeight + 0.5)
    let minLineHeight = -(fontLineHeight + ascenderDelta)
    
    // Calculate line spacing
    let lineSpacing = max(CGFloat(minLineHeight) + lineHeight, CGFloat(minLineHeight))

    // Build Attributes
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = 1
    paragraphStyle.alignment = alignment
    paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
    var attributes: [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: fillColor,
      NSAttributedString.Key.kern: tracking,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]
    
    let attrString = NSAttributedString(string: text, attributes: attributes)
    attributedString = attrString
    let setter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
    fillFrameSetter = setter

    // Calculate drawing size
    let textAnchor: CGPoint
    if let preferredSize = preferredSize {
      drawingRect = CGRect(origin: .zero, size: preferredSize)
      drawingRect.size.height += (ascent - capHeight)
      textAnchor = CGPoint(x: 0, y: ascent-capHeight)
    } else {
      let size = CTFramesetterSuggestFrameSizeWithConstraints(
        setter,
        CFRange(location: 0, length: attrString.length),
        nil,
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
        nil
      )
      switch alignment {
      case .left:
        textAnchor = CGPoint(x: 0, y: ascent)
      case .right:
        textAnchor = CGPoint(x: size.width, y: ascent)
      case .center:
        textAnchor = CGPoint(x: size.width * 0.5, y: ascent)
      default:
        textAnchor = .zero
      }
      drawingRect = CGRect(x: 0, y: 0, width: ceil(size.width),
                           height: ceil(size.height))
    }
    
    // Now Calculate Anchor
    drawingAnchor = CGPoint(x: textAnchor.x.remap(fromLow: 0, fromHigh: drawingRect.size.width, toLow: 0, toHigh: 1),
                            y: textAnchor.y.remap(fromLow: 0, fromHigh: drawingRect.size.height, toLow: 0, toHigh: 1))
    
    if let strokeColor = strokeColor {
      attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
      attributes[NSAttributedString.Key.strokeColor] = strokeColor
      let strokeAttributedString = NSAttributedString(string: text, attributes: attributes)
      strokeFrameSetter = CTFramesetterCreateWithAttributedString(strokeAttributedString as CFAttributedString)
      drawingRect.size.width += strokeWidth
      drawingRect.size.height += strokeWidth
    } else {
      strokeFrameSetter = nil
    }
  }
  
}
