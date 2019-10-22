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
import Cocoa

/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
import UIKit
#endif

class DisabledTextLayer: CATextLayer {
  override func action(forKey event: String) -> CAAction? {
    return nil
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
  let textLayer: CATextLayer
  let textStrokeLayer: CATextLayer
  var textProvider: AnimationTextProvider
  
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
        self.textLayer = WordAnimatedTextLayer()
        self.textStrokeLayer = WordAnimatedTextLayer()
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
    let scale = interpolatableScale?.value(frame: frame) as! Vector3D
    rootNode?.rebuildOutputs(frame: frame)
    
    let fillColor = rootNode?.textOutputNode.fillColor ?? text.fillColorData.cgColorValue
    let strokeColor = rootNode?.textOutputNode.strokeColor ?? text.strokeColorData?.cgColorValue
    let strokeWidth = rootNode?.textOutputNode.strokeWidth ?? CGFloat(text.strokeWidth ?? 0)
    let tracking = (CGFloat(text.fontSize) * (rootNode?.textOutputNode.tracking ?? CGFloat(text.tracking))) / 1000.0
//    TODO: Investigate what is wrong with transform matrix
//    let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
    let ctFont = CTFontCreateWithName(text.fontFamily as CFString, CGFloat(text.fontSize), nil)
    
    let textString = textProvider.textFor(keypathName: self.keypathName, sourceText: text.text)
    
	var nsFont : NSFont?
	fonts?.fonts.forEach({ (font) in
		if (font.name == text.fontFamily) {
			if (font.style == "UltraLight") {
				nsFont = NSFont().systemUIFontUltraLight(size: CGFloat(text.fontSize))
			}
			else if (font.style == "Thin") {
				nsFont = NSFont().systemUIFontThin(size: CGFloat(text.fontSize))
			}
			else if (font.style == "Light") {
				nsFont = NSFont().systemUIFontLight(size: CGFloat(text.fontSize))
			}
			else if (font.style == "Regular") {
				nsFont = NSFont().systemUIFontRegular(size: CGFloat(text.fontSize))
			}
			else if (font.style == "Medium") {
				nsFont = NSFont().systemUIFontMedium(size: CGFloat(text.fontSize))
			}
 		}
	})
	
	let resultFont = nsFont ?? CTFontCreateWithName(text.fontFamily as CFString, CGFloat(text.fontSize), nil) as NSFont
	var attributes: [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font: resultFont,
      NSAttributedString.Key.foregroundColor: fillColor,
      NSAttributedString.Key.kern: tracking,
    ]
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = CGFloat(text.lineHeight)
    paragraphStyle.alignment = text.justification?.textAlignment ?? NSTextAlignment.left
    attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
    
    let baseAttributedString = NSAttributedString(string: textString, attributes: attributes )
    
    if let strokeColor = strokeColor {
      textStrokeLayer.isHidden = false
      attributes[NSAttributedString.Key.strokeColor] = strokeColor
      attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
    } else {
      textStrokeLayer.isHidden = true
    }
    
    let size: CGSize
    let attributedString: NSAttributedString = NSAttributedString(string: textString, attributes: attributes )
    
    if let frameSize = text.textFrameSize {
      size = CGSize(width: frameSize.x, height: frameSize.y)
    } else {
      let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
      
      size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                          CFRange(location: 0,length: 0),
                                                          nil,
                                                          CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                 height: CGFloat.greatestFiniteMagnitude),
                                                          nil)
    }
    
    let baselinePosition = CTFontGetAscent(ctFont)
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
        let emptyPosition = CGPoint(x: -textAnchor.x, y: -CGFloat(text.fontSize * 0.9))
        layer.frame = CGRect(origin: text.textFramePosition?.pointValue ?? emptyPosition, size: size)
        //    TODO: Investigate what is wrong with transform matrix
        //    textLayer.transform = matrix
        
        layer.alignmentMode = text.justification?.caTextAlignement ?? CATextLayerAlignmentMode.left
        layer.contentsScale = 2.0
        layer.rasterizationScale = 2.0
        layer.string = baseAttributedString
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
    }
    
    setupLayer(layer: textLayer)
  }
}

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
