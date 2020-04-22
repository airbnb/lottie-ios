//
//  TextCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore
import CoreText

#if os(macOS)
import Cocoa
import AppKit
#else
import Foundation
import UIKit
#endif

class DisabledTextLayer: CATextLayer {
  var centeredVertically = false
  override func action(forKey event: String) -> CAAction? {
    return nil
  }
#if os(OSX)
    override func draw(in ctx: CGContext) {
        NSGraphicsContext.saveGraphicsState()
        if centeredVertically {
            // From https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer
            let lines = CGFloat((string as? NSAttributedString)?.linesCount(for: bounds.width) ?? 1)
            var yDiff = lines * fontSize / 10.0 - (bounds.height - lines * fontSize) / 2.0
            yDiff += (lines - 1.0) * fontSize / 4.0 // Line spacing
            ctx.translateBy(x: 0, y: -yDiff)
        }
        if #available(OSX 10.10, *) {
            NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)
        }
        (string as? NSAttributedString)?.draw(in: bounds)
        NSGraphicsContext.restoreGraphicsState()
    }
#endif
}

extension NSAttributedString {

    func linesCount(for width: CGFloat) -> Int {
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)), transform: nil)
        let frameSetterRef = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, nil)
        let linesNS = CTFrameGetLines(frameRef)

        guard let lines = linesNS as? [CTLine] else { return 1 }
        return lines.count
    }
}

extension TextJustification {
  var textAlignment: NSTextAlignment {
    switch self {
    case .left:
      return .left
    case .right:
      return .right
    case .center:
      return .center
    }
  }
  
  var caTextAlignement: CATextLayerAlignmentMode {
    switch self {
    case .left:
      return .left
    case .right:
      return .right
    case .center:
      return .center
    }
  }
  
}

class TextCompositionLayer: CompositionLayer {
  
  let rootNode: TextAnimatorNode?
  let textDocument: KeyframeInterpolator<TextDocument>?
  let interpolatableAnchorPoint: KeyframeInterpolator<Vector3D>?
  let interpolatableScale: KeyframeInterpolator<Vector3D>?
  
  let fonts : FontList?
  let textLayer: DisabledTextLayer
  let textStrokeLayer: CATextLayer
  var textProvider: AnimationTextProvider {
    didSet {
        guard let lastUpdatedFrame = textDocument?.lastUpdatedFrame else { return }
        displayContentsWithFrame(frame: lastUpdatedFrame, forceUpdates: true)
    }
  }
    
    override var renderScale: CGFloat {
        didSet {
            textLayer.contentsScale = self.renderScale
            textStrokeLayer.contentsScale = self.renderScale
        }
    }
  
  init(textLayer: TextLayerModel, textProvider: AnimationTextProvider, fonts: FontList?) {
    var rootNode: TextAnimatorNode?
    for animator in textLayer.animators {
      rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
    }
    self.rootNode = rootNode
    self.textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
    
    self.textProvider = textProvider
    
    // TODO: this has to be somewhere that can be interpolated
    // TODO: look for inspiration from other composite layer
    self.interpolatableAnchorPoint = KeyframeInterpolator(keyframes: textLayer.transform.anchorPoint.keyframes)
    self.interpolatableScale = KeyframeInterpolator(keyframes: textLayer.transform.scale.keyframes)
    
    self.fonts = fonts
    if (textLayer.effects?.first { $0.name == "Evolution_(%)_In" }) != nil {
        if textLayer.animators.first?.selector?.basedOn == .words {
            self.textLayer = WordAnimatedTextLayer(textLayer.parent != nil)
            self.textStrokeLayer = WordAnimatedTextLayer(textLayer.parent != nil)
        } else {
            self.textLayer = LineAnimatedTextLayer()
            self.textStrokeLayer = LineAnimatedTextLayer()
        }
    } else {
        self.textLayer = DisabledTextLayer()
        self.textStrokeLayer = DisabledTextLayer()
    }
    
    super.init(layer: textLayer, size: .zero)
    
    contentsLayer.addSublayer(self.textLayer)
    contentsLayer.addSublayer(self.textStrokeLayer)
    self.textLayer.masksToBounds = false
    self.textStrokeLayer.masksToBounds = false
    self.textLayer.isWrapped = true
    self.textStrokeLayer.isWrapped = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? TextCompositionLayer else {
      fatalError("init(layer:) Wrong Layer Class")
    }
    self.rootNode = nil
    self.textDocument = nil
    
    self.textProvider = DefaultTextProvider()
    
    self.interpolatableAnchorPoint = nil
    self.interpolatableScale = nil
    
    self.textLayer = DisabledTextLayer()
    self.textStrokeLayer = DisabledTextLayer()
    
	self.fonts = nil
    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    guard let textDocument = textDocument else { return }
    
    textLayer.contentsScale = self.renderScale
    textStrokeLayer.contentsScale = self.renderScale
    
    let documentUpdate = textDocument.hasUpdate(frame: frame)
    let animatorUpdate = rootNode?.updateContents(frame, forceLocalUpdate: forceUpdates) ?? false
    guard documentUpdate == true || animatorUpdate == true else { return }
    
    let text = textDocument.value(frame: frame) as! TextDocument
    let anchorPoint = interpolatableAnchorPoint?.value(frame: frame) as! Vector3D
    rootNode?.rebuildOutputs(frame: frame)
    
    let fillColor = rootNode?.textOutputNode.fillColor ?? text.fillColorData.cgColorValue
    let strokeColor = rootNode?.textOutputNode.strokeColor ?? text.strokeColorData?.cgColorValue
#if os(OSX)
    let nsFillColor = NSColor(cgColor: fillColor)
    var nsStrokeColor: NSColor? = nil
    if let strokeColor = strokeColor {
        nsStrokeColor = NSColor(cgColor: strokeColor)
    }
#endif
    
    let strokeWidth = rootNode?.textOutputNode.strokeWidth ?? CGFloat(text.strokeWidth ?? 0)
    let tracking = (CGFloat(text.fontSize) * (rootNode?.textOutputNode.tracking ?? CGFloat(text.tracking))) / 1000.0
    let matrix = rootNode?.textAnimatorProperties.caTransform ?? CATransform3DIdentity
    
#if os(macOS)
    let resultFont: NSFont
#else
    let resultFont: UIFont
#endif
    
    //  If font with the same family can be created, then use it.
    let fontFamily = text.fontFamily as CFString
    let ctFont = CTFontCreateWithName(fontFamily, CGFloat(text.fontSize), nil)
    if CTFontCopyPostScriptName(ctFont) == fontFamily {
        resultFont = ctFont
    }
    else {
    //  If not, then try to get system font instead ...
#if os(macOS)
        var systemFont : NSFont?
        fonts?.fonts.forEach({ (font) in
            if (font.name == text.fontFamily) {
                if (font.style == "UltraLight") {
                    systemFont = NSFont().systemUIFontUltraLight(size: CGFloat(text.fontSize))
                }
                else if (font.style == "Thin") {
                    systemFont = NSFont().systemUIFontThin(size: CGFloat(text.fontSize))
                }
                else if (font.style == "Light") {
                    systemFont = NSFont().systemUIFontLight(size: CGFloat(text.fontSize))
                }
                else if (font.style == "Regular") {
                    systemFont = NSFont().systemUIFontRegular(size: CGFloat(text.fontSize))
                }
                else if (font.style == "Medium") {
                    systemFont = NSFont().systemUIFontMedium(size: CGFloat(text.fontSize))
                }
                if (font.style == "Bold") {
                    systemFont = NSFont().systemUIFontBold(size: CGFloat(text.fontSize))
                }
            }
        })
#else
        var systemFont : UIFont?
        fonts?.fonts.forEach({ (font) in
            if (font.name == text.fontFamily) {
                if (font.style == "UltraLight") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .ultraLight)
                }
                else if (font.style == "Thin") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .thin)
                }
                else if (font.style == "Light") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .light)
                }
                else if (font.style == "Regular") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .regular)
                }
                else if (font.style == "Medium") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .medium)
                }
                else if (font.style == "Bold") {
                    systemFont = UIFont.systemFont(ofSize: CGFloat(text.fontSize), weight: .bold)
                }
            }
        })
#endif
        //  ... and use it if available, otherwise fallback to the ctFont
        resultFont = systemFont ?? ctFont
    }
	
	var attributes: [NSAttributedString.Key : Any] = [
      .font: resultFont,
      .kern: tracking,
    ]
    
#if os(OSX)
    attributes[.foregroundColor] = nsFillColor
#else
    attributes[.foregroundColor] = fillColor
#endif
    
    let baselinePosition = CTFontGetAscent(resultFont)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = CGFloat(text.fontSize / text.lineHeight) * 6
    paragraphStyle.alignment = text.justification?.textAlignment ?? NSTextAlignment.left
    attributes[.paragraphStyle] = paragraphStyle
    
    let textString = textProvider.textFor(keypathName: self.keypathName, sourceText: text.text)
    let baseAttributedString = NSAttributedString(string: textString, attributes: attributes)
    
    if let strokeColor = strokeColor {
      textStrokeLayer.isHidden = false
#if os(OSX)
      attributes[.strokeColor] = nsStrokeColor
#else
      attributes[.strokeColor] = strokeColor
#endif
      attributes[.strokeWidth] = strokeWidth
    } else {
      textStrokeLayer.isHidden = true
    }
    
    let strokeAttributedString: NSAttributedString = NSAttributedString(string: textString, attributes: attributes)
    let size: CGSize
    
    if let frameSize = text.textFrameSize {
      size = CGSize(width: frameSize.x, height: frameSize.y)
    } else {
      let framesetter = CTFramesetterCreateWithAttributedString(baseAttributedString)
      
      size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                          CFRange(location: 0,length: 0),
                                                          nil,
                                                          CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                 height: CGFloat.greatestFiniteMagnitude),
                                                          nil)
    }
    
    var textAnchor: CGPoint
    switch text.justification {
    case .left, .none:
      textAnchor = CGPoint(x: 0, y: baselinePosition)
    case .right:
      textAnchor = CGPoint(x: size.width, y: baselinePosition)
    case .center:
      textAnchor = CGPoint(x: size.width * 0.5, y: baselinePosition)
    }
    textAnchor.y += CGFloat(text.baseline ?? 0.0)
    let anchor = textAnchor + anchorPoint.pointValue
    let normalizedAnchor = CGPoint(x: anchor.x.remap(fromLow: 0, fromHigh: size.width, toLow: 0, toHigh: 1),
                                   y: anchor.y.remap(fromLow: 0, fromHigh: size.height, toLow: 0, toHigh: 1))
    
    func setupLayer(layer: CATextLayer) {
        layer.anchorPoint = normalizedAnchor
        layer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
        layer.transform = CATransform3DIdentity
        layer.fontSize = CGFloat(text.fontSize)
        layer.font = resultFont
        layer.foregroundColor = fillColor
        if let position = text.textFramePosition?.pointValue {
            layer.frame = CGRect(origin: position, size: size)
            layer.position.y -= CGFloat(text.fontSize * 0.2)
        } else {
            layer.frame = CGRect(origin: CGPoint(x: -textAnchor.x, y: -CGFloat(text.fontSize)), size: size)
        }
        if let wordLayer = layer as? WordAnimatedTextLayer {
            wordLayer.frame.origin.y += wordLayer.fontSize
            wordLayer.frame.size.height += wordLayer.fontSize
        }
        
        textLayer.transform = matrix
        
        layer.alignmentMode = text.justification?.caTextAlignement ?? CATextLayerAlignmentMode.left
    }
    
    if textStrokeLayer.isHidden == false {
      if text.strokeOverFill ?? false {
        textStrokeLayer.removeFromSuperlayer()
        contentsLayer.addSublayer(textStrokeLayer)
      } else {
        textLayer.removeFromSuperlayer()
        contentsLayer.addSublayer(textLayer)
      }
      setupLayer(layer: textStrokeLayer)
      textStrokeLayer.string = strokeAttributedString
    }
    
    setupLayer(layer: textLayer)
    textLayer.string = baseAttributedString
  }
}


#if os(macOS)

extension NSFont {
	
	func systemUIFontUltraLight(size: CGFloat) -> NSFont {
		var resultFont : NSFont
		if #available(OSX 10.11, *) {
			resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.ultraLight)
		}
		else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
			resultFont = CTFontCreateWithName("HelveticaNeue-UltraLight" as CFString, size, nil)
		}
		else {
			resultFont = systemUIFont(size: size, weightDelta: -3)
		}
		return resultFont
	}
	
	func systemUIFontThin(size: CGFloat) -> NSFont {
		var resultFont : NSFont
		if #available(OSX 10.11, *) {
			resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.thin)
		}
		else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
			resultFont = CTFontCreateWithName("HelveticaNeue-Thin" as CFString, size, nil)
		}
		else {
			resultFont = systemUIFont(size: size, weightDelta: -2)
		}
		return resultFont
	}
	
	func systemUIFontLight(size: CGFloat) -> NSFont {
		var resultFont : NSFont
		if #available(OSX 10.11, *) {
			resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.light)
		}
		else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
			resultFont = CTFontCreateWithName("HelveticaNeue-Light" as CFString, size, nil)
		}
		else {
			resultFont = systemUIFont(size: size, weightDelta: -1)
		}
		return resultFont
	}
	
	func systemUIFontRegular(size: CGFloat) -> NSFont {
		var resultFont : NSFont
		if #available(OSX 10.11, *) {
			resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.regular)
		}
		else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
			resultFont = CTFontCreateWithName("HelveticaNeue" as CFString, size, nil)
		}
		else {
			resultFont = systemUIFont(size: size, weightDelta: 0)
		}
		return resultFont
	}
	
	func systemUIFontMedium(size: CGFloat) -> NSFont {
		var resultFont : NSFont
		if #available(OSX 10.11, *) {
			resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.medium)
		}
		else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
			resultFont = CTFontCreateWithName("HelveticaNeue-Medium" as CFString, size, nil)
		}
		else {
			resultFont = systemUIFont(size: size, weightDelta: 1)
		}
		return resultFont
	}
    
    func systemUIFontBold(size: CGFloat) -> NSFont {
        var resultFont : NSFont
        if #available(OSX 10.11, *) {
            resultFont = NSFont.systemFont(ofSize: size, weight: NSFont.Weight.bold)
        }
        else if (floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber10_10)) {
            resultFont = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, size, nil)
        }
        else {
            resultFont = systemUIFont(size: size, weightDelta: 3)
        }
        return resultFont
    }
	
	func systemUIFont(size: CGFloat, weightDelta: Int) -> NSFont {
		var result = NSFont.systemFont(ofSize: size)
		let sharedFontManager = NSFontManager.shared
		var delta = weightDelta
		while (delta < 0) {
			delta += 1
			result = sharedFontManager.convertWeight(false, of: result)
		}
		while (delta > 0)
		{
			delta -= 1;
			result = sharedFontManager.convertWeight(true, of: result)
		}
		return result
	}
}

#endif
