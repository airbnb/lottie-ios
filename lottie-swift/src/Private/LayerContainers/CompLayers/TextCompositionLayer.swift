//
//  TestCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore
import CoreText
import Cocoa

class DisabledTextLayer: CATextLayer {
  override func action(forKey event: String) -> CAAction? {
    return nil
  }
}

class TextCompositionLayer: CompositionLayer {
  
  let rootNode: TextAnimatorNode?
  let textDocument: KeyframeInterpolator<TextDocument>?
  let fonts : FontList?
  let textLayer: DisabledTextLayer = DisabledTextLayer()
  
	init(textLayer: TextLayerModel, fonts: FontList?) {
    var rootNode: TextAnimatorNode?
    for animator in textLayer.animators {
      rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
    }
    self.rootNode = rootNode
    self.textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
    self.fonts = fonts
    super.init(layer: textLayer, size: .zero)
    contentsLayer.addSublayer(self.textLayer)
    self.textLayer.masksToBounds = false
    
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
	self.fonts = nil
    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    guard let textDocument = textDocument else { return }
    let documentUpdate = textDocument.hasUpdate(frame: frame)
    let animatorUpdate = rootNode?.updateContents(frame, forceLocalUpdate: forceUpdates) ?? false
    guard documentUpdate == true || animatorUpdate == true else { return }
    
    let text = textDocument.value(frame: frame) as! TextDocument
    rootNode?.rebuildOutputs(frame: frame)
    
    let fillColor = rootNode?.textOutputNode.fillColor ?? text.fillColorData.cgColorValue
    let strokeColor = rootNode?.textOutputNode.strokeColor ?? text.strokeColorData?.cgColorValue
    let strokeWidth = rootNode?.textOutputNode.strokeWidth ?? CGFloat(text.strokeWidth ?? 0)
    let tracking = (CGFloat(text.fontSize) * (rootNode?.textOutputNode.tracking ?? CGFloat(text.tracking))) / 1000.0
    // TODO LINE HEIGHT
    
    let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
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
    
    if let strokeColor = strokeColor {
      attributes[NSAttributedString.Key.strokeColor] = strokeColor
      attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
    }
    
    let attributedString = NSAttributedString(string: text.text, attributes: attributes )
    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                            CFRange(location: 0,length: 0),
                                                            nil,
                                                            CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                   height: CGFloat.greatestFiniteMagnitude),
                                                            nil)
    switch text.justification {
    case .left:
      textLayer.anchorPoint = CGPoint(x: 0, y: 1)
    case .right:
      textLayer.anchorPoint = CGPoint(x: 1, y: 1)
    case .center:
      textLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
    }
    textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
    textLayer.transform = CATransform3DIdentity
    textLayer.frame = CGRect(origin: .zero, size: size)
    textLayer.position = CGPoint.zero
    textLayer.transform = matrix
    textLayer.string = attributedString
    textLayer.contentsScale = 2.0
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
