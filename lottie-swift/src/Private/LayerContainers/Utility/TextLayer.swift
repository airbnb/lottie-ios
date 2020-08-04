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



final class TextLayer: CALayer {
  
  public var attributedText: NSAttributedString? {
    didSet {
      needsSizeUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var preferredSize: CGSize? {
    didSet {
      needsSizeUpdate = true
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var strokeColor: CGColor? {
    didSet {
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  public var strokeWidth: CGFloat? {
    didSet {
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
  
  public func sizeToFit() {
    calculateContentSize()
    bounds = drawingRect
    self.setNeedsLayout()
    self.setNeedsDisplay()
  }
  
  override func action(forKey event: String) -> CAAction? {
    return nil
  }
  
  private var needsSizeUpdate: Bool = false
  
  
  override func draw(in ctx: CGContext) {
    guard let attributedString = attributedText else { return }
    calculateContentSize()
    if #available(iOS 13.0, *) {
      ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1))
    } else {
      // Fallback on earlier versions
    }
    ctx.fill(bounds)
    
    if #available(iOS 13.0, *) {
      ctx.setFillColor(CGColor(srgbRed: 0, green: 1, blue: 1, alpha: 1))
    } else {
      // Fallback on earlier versions
    }
    ctx.fill(drawingRect)
    
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
    let setter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
    let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedString.length), drawingPath, nil)
    CTFrameDraw(frame, ctx)
  }
  
  private var drawingRect: CGRect = .zero
  
  private func calculateContentSize() {
    guard needsSizeUpdate else { return }
    
    if let preferredSize = preferredSize {
      drawingRect = CGRect(origin: .zero, size: preferredSize)
      return
    }

    guard let attributedString = attributedText else {
      drawingRect = .zero
      return
    }
    
    if attributedString.length == 0 {
      drawingRect = .zero
      return
    }
    
    let setter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(
      setter,
      CFRange(location: 0, length: attributedString.length),
      nil,
      CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
      nil
    )
    drawingRect = CGRect(x: 0, y: 0, width: ceil(size.width),
                         height: ceil(size.height))
    needsSizeUpdate = false
  }
  
}
