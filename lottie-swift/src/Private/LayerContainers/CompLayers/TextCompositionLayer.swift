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

/// Needed for NSMutableParagraphStyle...
#if os(OSX)
import AppKit
#else
import UIKit
#endif

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

final class TextCompositionLayer: CompositionLayer {
  
  let rootNode: TextAnimatorNode?
  let textDocument: KeyframeInterpolator<TextDocument>?
  
  let textLayer: TextLayer = TextLayer()
  var textProvider: AnimationTextProvider
  
  init(textLayer: TextLayerModel, textProvider: AnimationTextProvider) {
    var rootNode: TextAnimatorNode?
    for animator in textLayer.animators {
      rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
    }
    self.rootNode = rootNode
    self.textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
    
    self.textProvider = textProvider
    
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
    
    self.textProvider = DefaultTextProvider()
    
    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    guard let textDocument = textDocument else { return }
    
    textLayer.contentsScale = self.renderScale
    
    let documentUpdate = textDocument.hasUpdate(frame: frame)
    let animatorUpdate = rootNode?.updateContents(frame, forceLocalUpdate: forceUpdates) ?? false
//    guard documentUpdate == true || animatorUpdate == true else { return }
    
    rootNode?.rebuildOutputs(frame: frame)
    
    // Get Text Attributes
    let text = textDocument.value(frame: frame) as! TextDocument
    let fillColor = rootNode?.textOutputNode.fillColor ?? text.fillColorData.cgColorValue
    let strokeColor = rootNode?.textOutputNode.strokeColor ?? text.strokeColorData?.cgColorValue
    let strokeWidth = rootNode?.textOutputNode.strokeWidth ?? CGFloat(text.strokeWidth ?? 0)
    let tracking = (CGFloat(text.fontSize) * (rootNode?.textOutputNode.tracking ?? CGFloat(text.tracking))) / 1000.0
    let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
    let textString = textProvider.textFor(keypathName: self.keypathName, sourceText: text.text)
    
    let ctFont = CTFontCreateWithName(text.fontFamily as CFString, CGFloat(text.fontSize), nil)
    let ascent = CTFontGetAscent(ctFont)
    let descent = CTFontGetDescent(ctFont)
    let leading = floor(max(CTFontGetLeading(ctFont), 0) + 0.5)
    let fontLineHeight = floor(ascent + 0.5) + floor(descent + 0.5) + leading
    let ascenderDelta = leading > 0 ? 0 : floor (0.2 * fontLineHeight + 0.5)
    let minLineHeight = -(fontLineHeight + ascenderDelta)
    let lineHeight = max(CGFloat(minLineHeight) + CGFloat(text.lineHeight), CGFloat(minLineHeight))

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineHeight
    paragraphStyle.lineHeightMultiple = 1
    paragraphStyle.alignment = text.justification.textAlignment
    paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

    let attributes: [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font: ctFont,
      NSAttributedString.Key.foregroundColor: fillColor,
      NSAttributedString.Key.kern: tracking,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]
    
    // Set all of the text layer options
    textLayer.preferredSize = text.textFrameSize?.sizeValue
    textLayer.attributedText = NSMutableAttributedString(string: textString, attributes: attributes )
    textLayer.strokeOnTop = text.strokeOverFill ?? false
    textLayer.strokeWidth = strokeWidth
    textLayer.strokeColor = strokeColor
    textLayer.sizeToFit()
    
    let normalizedAnchor: CGPoint
    if text.textFrameSize != nil {
      normalizedAnchor = CGPoint.zero
    } else {
      let size = textLayer.bounds.size
      let baselinePosition = CTFontGetAscent(ctFont)
      let textAnchor: CGPoint
      switch text.justification {
      case .left:
        textAnchor = CGPoint(x: 0, y: baselinePosition)
      case .right:
        textAnchor = CGPoint(x: size.width, y: baselinePosition)
      case .center:
        textAnchor = CGPoint(x: size.width * 0.5, y: baselinePosition)
      }
      normalizedAnchor = CGPoint(x: textAnchor.x.remap(fromLow: 0, fromHigh: size.width, toLow: 0, toHigh: 1),
                                 y: textAnchor.y.remap(fromLow: 0, fromHigh: size.height, toLow: 0, toHigh: 1))
    }

    textLayer.anchorPoint = normalizedAnchor
    textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
    textLayer.transform = CATransform3DIdentity
    textLayer.position = text.textFramePosition?.pointValue ?? CGPoint.zero
    textLayer.transform = matrix
  }
  
  override func updateRenderScale() {
    super.updateRenderScale()
    textLayer.contentsScale = self.renderScale
  }
}
