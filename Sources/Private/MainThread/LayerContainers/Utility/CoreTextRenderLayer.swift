//
//  TextLayer.swift
//  Pods
//
//  Created by Brandon Withrow on 8/3/20.
//

import CoreGraphics
import CoreText
import Foundation
#if os(watchOS)
import CAShim
#else
import QuartzCore
#endif
/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
#if !os(watchOS)
import UIKit
#endif
#endif

// MARK: - CoreTextRenderLayer

/// A CALayer subclass that renders text content using CoreText
final class CoreTextRenderLayer: CALayer {

  // MARK: Internal

  var text: String? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var font: CTFont? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var alignment = NSTextAlignment.left {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var lineHeight: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var tracking: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var fillColor: CGColor? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var strokeColor: CGColor? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var strokeWidth: CGFloat = 0 {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var strokeOnTop = false {
    didSet {
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var preferredSize: CGSize? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var start: Int? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  var end: Int? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  /// The type of unit to use when computing the `start` / `end` range within the text string
  var textRangeUnit: TextRangeUnit? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  /// The opacity to apply to the range between `start` and `end`
  var selectedRangeOpacity: CGFloat? {
    didSet {
      needsContentUpdate = true
      setNeedsLayout()
      setNeedsDisplay()
    }
  }

  func sizeToFit() {
    updateTextContent()
    bounds = drawingRect
    anchorPoint = drawingAnchor
    setNeedsLayout()
    setNeedsDisplay()
  }

  override func action(forKey _: String) -> CAAction? {
    nil
  }

  override func draw(in ctx: CGContext) {
    guard let attributedString else { return }
    updateTextContent()
    guard fillFrameSetter != nil || strokeFrameSetter != nil else { return }

    ctx.textMatrix = .identity
    ctx.setAllowsAntialiasing(true)
    ctx.setAllowsFontSubpixelPositioning(true)
    ctx.setAllowsFontSubpixelQuantization(true)

    ctx.setShouldAntialias(true)
    ctx.setShouldSubpixelPositionFonts(true)
    ctx.setShouldSubpixelQuantizeFonts(true)

    if contentsAreFlipped() {
      ctx.translateBy(x: 0, y: drawingRect.height)
      ctx.scaleBy(x: 1.0, y: -1.0)
    }

    let drawingPath = CGPath(rect: drawingRect, transform: nil)
    if preferredSize == nil {
      let horizontalOffset: CGFloat =
        switch alignment {
        case .left:
          compensationPadding
        case .right:
          -compensationPadding
        default:
          0
        }
      ctx.translateBy(x: horizontalOffset, y: 0)
    }

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
    // For some reason some fonts, such as Helvetica draw with an ascender that is greater than the one reported by CTFontGetAscender.
    // I suspect this is actually an issue with the Attributed string, but cannot reproduce.

    if let fillFrame {
      ctx.adjustWithLineOrigins(in: fillFrame, with: font)
    } else if let strokeFrame {
      ctx.adjustWithLineOrigins(in: strokeFrame, with: font)
    }

    if !strokeOnTop, let strokeFrame {
      CTFrameDraw(strokeFrame, ctx)
    }

    if let fillFrame {
      CTFrameDraw(fillFrame, ctx)
    }

    if strokeOnTop, let strokeFrame {
      CTFrameDraw(strokeFrame, ctx)
    }
  }

  // MARK: Private

  private var drawingRect = CGRect.zero
  private var drawingAnchor = CGPoint.zero
  private var fillFrameSetter: CTFramesetter?
  private var attributedString: NSAttributedString?
  private var strokeFrameSetter: CTFramesetter?
  private var needsContentUpdate = false

  /// Horizontal compensation padding for the fonts that report wrong geometry.
  ///
  /// Some fonts have symbols that are drawn beyond the suggested frame
  /// that CoreText returns, especially calligraphy fonts. This padding tries to compensate for that.
  /// Because we can't know for sure the real size of the text,
  /// the 20% value was experimentally chosen to account for most such cases.
  private var compensationPadding: CGFloat {
    (font.map(CTFontGetSize) ?? 0) * 0.2
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

    // Get Font properties
    let ascent = CTFontGetAscent(font)
    let descent = CTFontGetDescent(font)
    let capHeight = CTFontGetCapHeight(font)
    let leading = CTFontGetLeading(font)
    let minLineHeight = -(ascent + descent + leading)

    // Calculate line spacing
    let lineSpacing = max(CGFloat(minLineHeight) + lineHeight, CGFloat(minLineHeight))
    // Build Attributes
    let paragraphStyle = lottieMakeParagraphStyle(
      lineSpacing: lineSpacing,
      maximumLineHeight: ascent + descent + leading,
      alignment: alignment
    )
    var attributes: [NSAttributedString.Key: Any] = [
      lottieLigatureKey: 0,
      lottieFontKey: font,
      lottieKernKey: tracking,
      lottieParagraphStyleKey: paragraphStyle,
    ]

    if let fillColor {
      attributes[lottieForegroundColorKey] = fillColor
    }

    let attrString = NSMutableAttributedString(string: text, attributes: attributes)

    // Apply the text animator within between the `start` and `end` indices
    if let selectedRangeOpacity {
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
      let textRangeColor: CGColor
      if let fillColor {
        if let (r, g, b) = fillColor.rgb {
          textRangeColor = .rgba(r, g, b, selectedRangeOpacity)
        } else {
          LottieLogger.shared.warn("Could not convert color \(fillColor) to RGB values.")
          textRangeColor = .rgba(0, 0, 0, selectedRangeOpacity)
        }
      } else {
        textRangeColor = .rgba(0, 0, 0, selectedRangeOpacity)
      }

      attrString.addAttribute(
        lottieForegroundColorKey,
        value: textRangeColor,
        range: NSRange(location: startIndex, length: endIndex - startIndex)
      )
    }

    attributedString = attrString

    if fillColor != nil {
      let setter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
      fillFrameSetter = setter
    } else {
      fillFrameSetter = nil
    }

    if let strokeColor {
      attributes[lottieForegroundColorKey] = nil
      attributes[lottieStrokeWidthKey] = strokeWidth
      attributes[lottieStrokeColorKey] = strokeColor
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
      let size = CTFramesetterSuggestFrameSizeWithConstraints(
        setter,
        CFRange(location: 0, length: attrString.length),
        nil,
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
        nil
      )

      // Suggested size + horizontal compensation for fonts with inaccurate geometry.
      let adjustedSize = CGSize(width: size.width + compensationPadding * 2, height: size.height)

      switch alignment {
      case .left:
        textAnchor = CGPoint(x: compensationPadding, y: ascent)
      case .right:
        textAnchor = CGPoint(x: adjustedSize.width - compensationPadding, y: ascent)
      case .center:
        textAnchor = CGPoint(x: adjustedSize.width * 0.5, y: ascent)
      default:
        textAnchor = .zero
      }
      drawingRect = CGRect(
        x: 0,
        y: 0,
        width: ceil(adjustedSize.width),
        height: ceil(adjustedSize.height)
      )
    }

    // Now Calculate Anchor
    drawingAnchor = CGPoint(
      x: textAnchor.x.remap(fromLow: 0, fromHigh: drawingRect.size.width, toLow: 0, toHigh: 1),
      y: textAnchor.y.remap(fromLow: 0, fromHigh: drawingRect.size.height, toLow: 0, toHigh: 1)
    )

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
    if diff > 0 {
      translateBy(x: 0, y: diff)
    }
  }
}

#if os(watchOS)
/// `NSAttributedString.Key.foregroundColor` is declared by UIKit, which this
/// build cannot import. CoreText's own key is the same string.
let lottieForegroundColorKey = NSAttributedString.Key(kCTForegroundColorAttributeName as String)
#else
let lottieForegroundColorKey = NSAttributedString.Key.foregroundColor
#endif

#if os(watchOS)
let lottieStrokeWidthKey = NSAttributedString.Key(kCTStrokeWidthAttributeName as String)
let lottieStrokeColorKey = NSAttributedString.Key(kCTStrokeColorAttributeName as String)
let lottieParagraphStyleKey = NSAttributedString.Key(kCTParagraphStyleAttributeName as String)
#else
let lottieStrokeWidthKey = NSAttributedString.Key.strokeWidth
let lottieStrokeColorKey = NSAttributedString.Key.strokeColor
let lottieParagraphStyleKey = NSAttributedString.Key.paragraphStyle
#endif

#if os(watchOS)
import CoreText

let lottieFontKey = NSAttributedString.Key(kCTFontAttributeName as String)
let lottieKernKey = NSAttributedString.Key(kCTKernAttributeName as String)
let lottieLigatureKey = NSAttributedString.Key(kCTLigatureAttributeName as String)

/// UIKit's `NSMutableParagraphStyle` is not reachable from this build, so the
/// same settings are expressed with CoreText's own paragraph style, which is
/// what the text is ultimately drawn with in any case.
func lottieMakeParagraphStyle(
  lineSpacing: CGFloat,
  maximumLineHeight: CGFloat,
  alignment: NSTextAlignment
) -> CTParagraphStyle {
  var ctAlignment: CTTextAlignment =
    switch alignment {
    case .left: .left
    case .center: .center
    case .right: .right
    case .justified: .justified
    case .natural: .natural
    }
  var spacing = lineSpacing
  var maxHeight = maximumLineHeight
  var wrap = CTLineBreakMode.byWordWrapping

  // `CTParagraphStyleSetting` holds a raw pointer to each value, so the values
  // have to outlive the array. Taking `&x` inside the literal would not.
  return withUnsafePointer(to: &ctAlignment) { alignment in
    withUnsafePointer(to: &spacing) { spacing in
      withUnsafePointer(to: &maxHeight) { maxHeight in
        withUnsafePointer(to: &wrap) { wrap in
          let settings = [
            CTParagraphStyleSetting(
              spec: .alignment,
              valueSize: MemoryLayout<CTTextAlignment>.size,
              value: alignment
            ),
            CTParagraphStyleSetting(
              spec: .lineSpacingAdjustment,
              valueSize: MemoryLayout<CGFloat>.size,
              value: spacing
            ),
            CTParagraphStyleSetting(
              spec: .maximumLineHeight,
              valueSize: MemoryLayout<CGFloat>.size,
              value: maxHeight
            ),
            CTParagraphStyleSetting(
              spec: .lineBreakMode,
              valueSize: MemoryLayout<CTLineBreakMode>.size,
              value: wrap
            ),
          ]
          return CTParagraphStyleCreate(settings, settings.count)
        }
      }
    }
  }
}
#else
let lottieFontKey = NSAttributedString.Key.font
let lottieKernKey = NSAttributedString.Key.kern
let lottieLigatureKey = NSAttributedString.Key.ligature

func lottieMakeParagraphStyle(
  lineSpacing: CGFloat,
  maximumLineHeight: CGFloat,
  alignment: NSTextAlignment
) -> NSParagraphStyle {
  let style = NSMutableParagraphStyle()
  style.lineSpacing = lineSpacing
  style.lineHeightMultiple = 1
  style.maximumLineHeight = maximumLineHeight
  style.alignment = alignment
  style.lineBreakMode = .byWordWrapping
  return style
}
#endif
