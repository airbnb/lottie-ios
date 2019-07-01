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

class TextCompositionLayer: CompositionLayer {
  
  let rootNode: TextAnimatorNode?
  let textDocument: KeyframeInterpolator<TextDocument>?
  let interpolatableAnchorPoint: KeyframeInterpolator<Vector3D>?
  let interpolatableScale: KeyframeInterpolator<Vector3D>?
  
  let textLayer: DisabledTextLayer = DisabledTextLayer()
  var textProvider: AnimationTextProvider
  
  init(textLayer: TextLayerModel, textProvider: AnimationTextProvider) {
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

    self.interpolatableAnchorPoint = nil
    self.interpolatableScale = nil

    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    guard let textDocument = textDocument else { return }
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
    // TODO LINE HEIGHT
    
    let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
    let ctFont = CTFontCreateWithName(text.fontFamily as CFString, CGFloat(text.fontSize), nil)
    
    var attributes: [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font: ctFont,
      NSAttributedString.Key.foregroundColor: fillColor,
      NSAttributedString.Key.kern: tracking,
      ]
    
    if let strokeColor = strokeColor {
      attributes[NSAttributedString.Key.strokeColor] = strokeColor
      attributes[NSAttributedString.Key.strokeWidth] = strokeWidth
    }
    

    let textString = textProvider.textFor(keypathName: self.keypathName, sourceText: text.text)
    let attributedString = NSAttributedString(string: textString, attributes: attributes )

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = CGFloat(text.lineHeight)
    attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
    

    let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
    let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                            CFRange(location: 0,length: 0),
                                                            nil,
                                                            CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                   height: CGFloat.greatestFiniteMagnitude),
                                                            nil)
    
    textLayer.anchorPoint = self.calculateAnchor(withAnchorPoint: anchorPoint, justification: text.justification, scale: scale, andSize: size)
    textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
    textLayer.transform = CATransform3DIdentity
    textLayer.frame = CGRect(origin: .zero, size: size)
    textLayer.position = CGPoint.zero
    textLayer.transform = matrix
    textLayer.string = attributedString
  }
  
  private func calculateAnchor(withAnchorPoint anchorPoint: Vector3D, justification: TextJustification, scale: Vector3D, andSize size: CGSize) -> CGPoint {
    let calibratedAnchorPoint = CGPoint(x: (anchorPoint.x / Double(size.width) * (scale.x / 100.0)),
                                        y: (anchorPoint.y / Double(size.height) * (scale.y / 100.0)))
    
    let justificationAnchorPoint: CGPoint
    switch justification {
    case .left:
      justificationAnchorPoint = CGPoint(x: 0, y: 1)
    case .right:
      justificationAnchorPoint = CGPoint(x: 1, y: 1)
    case .center:
      justificationAnchorPoint = CGPoint(x: 0.5, y: 1)
    }

    return calibratedAnchorPoint + justificationAnchorPoint
  }
}
