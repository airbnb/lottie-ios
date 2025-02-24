//
//  TextCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

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
                .left
        case .right:
                .right
        case .center:
                .center
        }
    }
    
    var caTextAlignement: CATextLayerAlignmentMode {
        switch self {
        case .left:
                .left
        case .right:
                .right
        case .center:
                .center
        }
    }
}

// MARK: - TextCompositionLayer

final class TextCompositionLayer: CompositionLayer {
    
    // MARK: Lifecycle
    
    init(
        textLayer: TextLayerModel,
        textProvider: AnimationKeypathTextProvider,
        fontProvider: AnimationFontProvider,
        rootAnimationLayer: MainThreadAnimationLayer?)
    {
        var rootNode: TextAnimatorNode?
        for animator in textLayer.animators {
            rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
        }
        self.rootNode = rootNode
        textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
        
        self.textProvider = textProvider
        self.fontProvider = fontProvider
        self.rootAnimationLayer = rootAnimationLayer
        
        super.init(layer: textLayer, size: .zero)
        contentsLayer.addSublayer(self.textLayer)
//        self.textLayer.frame = CGRect(x: 0, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        
        self.textLayer.masksToBounds = false
        self.textLayer.isGeometryFlipped = true
//        self.addSublayer(self.textLayer)
//        contentsLayer.backgroundColor = UIColor.red.cgColor
//        self.backgroundColor = UIColor.red.cgColor
        if let rootNode {
            childKeypaths.append(rootNode)
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? TextCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        rootNode = nil
        textDocument = nil
        
        textProvider = DefaultTextProvider()
        fontProvider = DefaultFontProvider()
        
        super.init(layer: layer)
    }
    
    // MARK: Internal
    
    let rootNode: TextAnimatorNode?
    let textDocument: KeyframeInterpolator<TextDocument>?
    
    let textLayer = CoreTextRenderLayer()
    var textProvider: AnimationKeypathTextProvider
    var fontProvider: AnimationFontProvider
    weak var rootAnimationLayer: MainThreadAnimationLayer?
    
    lazy var fullAnimationKeypath: AnimationKeypath = // Individual layers don't know their full keypaths, so we have to delegate
    // to the `MainThreadAnimationLayer` to search the layer hierarchy and find
    // the full keypath (which includes this layer's parent layers)
    rootAnimationLayer?.keypath(for: self)
    // If that failed for some reason, just use the last path component (which we do have here)
    ?? AnimationKeypath(keypath: keypathName)
    
    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        guard let textDocument else { return }
        
        textLayer.contentsScale = renderScale
        
        let documentUpdate = textDocument.hasUpdate(frame: frame)
        let animatorUpdate = rootNode?.updateContents(frame, forceLocalUpdate: forceUpdates) ?? false
        guard documentUpdate == true || animatorUpdate == true else { return }
        
        rootNode?.rebuildOutputs(frame: frame)
        
        // Get Text Attributes
        let text = textDocument.value(frame: frame) as! TextDocument
        
        // Prior to Lottie 4.3.0 the Main Thread rendering engine always just used `LegacyAnimationTextProvider`
        // and called it with the `keypathName` (only the last path component of the full keypath).
        // Starting in Lottie 4.3.0 we use `AnimationKeypathTextProvider` instead if implemented.
        let textString: String =
        if let keypathTextValue = textProvider.text(for: fullAnimationKeypath, sourceText: text.text) {
            keypathTextValue
        } else if let legacyTextProvider = textProvider as? LegacyAnimationTextProvider {
            legacyTextProvider.textFor(keypathName: keypathName, sourceText: text.text)
        } else {
            text.text
        }
        
        var strokeColor:CGColor?
        
        if let newStrokeColor = textProvider.updateTextStrokeColor(text.strokeColorData?.cgColorValue) {
            strokeColor = newStrokeColor
        } else if let newStrokeColor = rootNode?.textOutputNode.strokeColor {
            strokeColor = newStrokeColor
        } else {
            strokeColor = text.strokeColorData?.cgColorValue
        }
        
        var strokeWidth:CGFloat = 0
        if let newStrokeWidth = textProvider.updateTextStrokeWidth(text.strokeWidth) {
            strokeWidth = newStrokeWidth
        } else if let newStrokeWidth = rootNode?.textOutputNode.strokeWidth {
            strokeWidth = newStrokeWidth + 3
        } else {
            strokeWidth = CGFloat(text.strokeWidth ?? 0)
        }
        var tracking:CGFloat = 0
        if let worldSpace = textProvider.updateWorldSpacing(CGFloat(text.tracking)) {
            tracking = worldSpace
        } else {
            tracking = (CGFloat(text.fontSize) * (rootNode?.textOutputNode.tracking ?? CGFloat(text.tracking))) / 1000.0
        }
        let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
        let ctFont = fontProvider.fontFor(family: text.fontFamily, size: CGFloat(text.fontSize))
        let start = rootNode?.textOutputNode.start.flatMap { Int($0) }
        let end = rootNode?.textOutputNode.end.flatMap { Int($0) }
        let selectedRangeOpacity = rootNode?.textOutputNode.selectedRangeOpacity
        let textRangeUnit = rootNode?.textAnimatorProperties.textRangeUnit
        let sttrange = rootNode?.textAnimatorProperties.start?.value.value
        let endrange = rootNode?.textAnimatorProperties.end?.value.value
        // Set all of the text layer options
        textLayer.text = textString
        textLayer.font = ctFont
        if let customAlignment = textProvider.updateTextAlinment() {
            textLayer.alignment = customAlignment
        } else {
            textLayer.alignment = text.justification.textAlignment
        }
        
        
        if let lineHeght = textProvider.updateLineHieght(text.lineHeight) {
            textLayer.lineHeight = CGFloat(lineHeght)
        } else {
            textLayer.lineHeight = CGFloat(text.lineHeight)
        }
        
        if let backColor = textProvider.updateTextBackgroundColor() {
            textLayer.backColor = backColor
        } else {
            textLayer.backColor = nil
        }
        
        
        textLayer.tracking = tracking
        if let textRangeData = textProvider.updateRangeText() {
            // Configure the text animators
            textLayer.start = textRangeData.start
            textLayer.end = textRangeData.end
            textLayer.textRangeUnit = textRangeData.rangeUnit
            textLayer.selectedRangeOpacity = textRangeData.rangeOpacity
            textLayer.textRangeFont = textRangeData.rangeFont
            textLayer.textRangeColor = textRangeData.rangeColor
        } else {
            // Configure the text animators
            textLayer.start = start
            textLayer.end = end
            if let newEnd = end, newEnd > 0 {
                if start == nil {
                    textLayer.start = 0
                }
            }
            textLayer.textRangeUnit = textRangeUnit
            textLayer.selectedRangeOpacity = selectedRangeOpacity
            textLayer.textRangeColor = rootNode?.textOutputNode.fillColor
        }
       
        if let fillColor = textProvider.updateTextFillColor(text.fillColorData?.cgColorValue) {
            textLayer.fillColor = fillColor
        } else if let fillColor = text.fillColorData?.cgColorValue {
            textLayer.fillColor = fillColor
        } else if let fillColor = rootNode?.textOutputNode.fillColor {
            textLayer.fillColor = fillColor
        } else {
            textLayer.fillColor = nil
        }
        
        
        if let underLine = textProvider.updateShowUnderLine() {
            textLayer.showUnderLine = underLine
        } else {
            textLayer.showUnderLine = false
        }
        
        textLayer.preferredSize = text.textFrameSize?.sizeValue
        textLayer.strokeOnTop = text.strokeOverFill ?? false
        textLayer.strokeWidth = strokeWidth
        textLayer.strokeColor = strokeColor
        textLayer.sizeToFit()
        
        textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
        textLayer.transform = CATransform3DIdentity
        textLayer.position = text.textFramePosition?.pointValue ?? CGPoint.zero
        textLayer.transform = matrix
    }
    
    override func updateRenderScale() {
        super.updateRenderScale()
        textLayer.contentsScale = renderScale
    }
}
