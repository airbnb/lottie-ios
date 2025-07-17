// Created by Cal Stephens on 2/9/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

/// The `CALayer` type responsible for rendering `TextLayer`s
final class TextLayer: BaseCompositionLayer {
    
    // MARK: Lifecycle
    
    init(
        textLayerModel: TextLayerModel,
        context: LayerContext)
    throws
    {
        self.textLayerModel = textLayerModel
        var rootNode: TextAnimatorNode?
        for animator in textLayerModel.animators {
            rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
        }
        
        self.rootNode = rootNode
        super.init(layerModel: textLayerModel)
        setupSublayers()
        try configureRenderLayer(with: context)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /// Called by CoreAnimation to create a shadow copy of this layer
    /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    override init(layer: Any) {
        guard let typedLayer = layer as? Self else {
            fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
        }
        
        textLayerModel = typedLayer.textLayerModel
        var rootNode: TextAnimatorNode?
        for animator in textLayerModel.animators {
            rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
        }
        
        self.rootNode = rootNode
        super.init(layer: typedLayer)
    }
    
    // MARK: Internal
    
    override func setupAnimations(context: LayerAnimationContext) throws {
        try super.setupAnimations(context: context)
        let textAnimationContext = context.addingKeypathComponent(textLayerModel.name)
        
        let sourceText = try textLayerModel.text.exactlyOneKeyframe(
            context: textAnimationContext,
            description: "text layer text")
        
        // Prior to Lottie 4.3.0 the Core Animation rendering engine always just used `LegacyAnimationTextProvider`
        // but incorrectly called it with the full keypath string, unlike the Main Thread rendering engine
        // which only used the last component of the keypath. Starting in Lottie 4.3.0 we use `AnimationKeypathTextProvider`
        // instead if implemented.
        if let keypathTextValue = context.textProvider.text(for: textAnimationContext.currentKeypath, sourceText: sourceText.text) {
            renderLayer.text = keypathTextValue
        } else if let legacyTextProvider = context.textProvider as? LegacyAnimationTextProvider {
            renderLayer.text = legacyTextProvider.textFor(
                keypathName: textAnimationContext.currentKeypath.fullPath,
                sourceText: sourceText.text)
        } else {
            renderLayer.text = sourceText.text
        }
        
        renderLayer.sizeToFit()
    }
    
   

  func configureRenderLayer(with context: LayerContext) throws {
    // We can't use `CATextLayer`, because it doesn't support enough features we use.
    // Instead, we use the same `CoreTextRenderLayer` (with a custom `draw` implementation)
    // used by the Main Thread rendering engine. This means the Core Animation engine can't
    // _animate_ text properties, but it can display static text without any issues.
    let text = try textLayerModel.text.exactlyOneKeyframe(context: context, description: "text layer text")

    // The Core Animation engine doesn't currently support `TextAnimator`s.
    //  - We could add support for animating the transform-related properties without much trouble.
    //  - We may be able to support animating `fillColor` by getting clever with layer blend modes
    //    or masks (e.g. use `CoreTextRenderLayer` to draw black glyphs, and then fill them in
    //    using a `CAShapeLayer`).
    if !textLayerModel.animators.isEmpty {
      try context.logCompatibilityIssue("""
        The Core Animation rendering engine currently doesn't support text animators.
        """)
        }
        
        
        let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity
        let start = rootNode?.textOutputNode.start.flatMap { Int($0) }
        let end = rootNode?.textOutputNode.end.flatMap { Int($0) }
        let selectedRangeOpacity = rootNode?.textOutputNode.selectedRangeOpacity
        let textRangeUnit = rootNode?.textAnimatorProperties.textRangeUnit
        let sttrange = rootNode?.textAnimatorProperties.start?.value.value
        let endrange = rootNode?.textAnimatorProperties.end?.value.value
        
        renderLayer.font = context.fontProvider.fontFor(family: text.fontFamily, size: CGFloat(text.fontSize))
        
        if let customAlignment = context.textProvider.updateTextAlinment() {
            renderLayer.alignment = customAlignment
        } else {
            renderLayer.alignment = text.justification.textAlignment
        }
        
        if let lineHeght = context.textProvider.updateLineHieght(text.lineHeight) {
            renderLayer.lineHeight = CGFloat(lineHeght)
        } else {
            renderLayer.lineHeight = CGFloat(text.lineHeight)
        }
        
        
        
        if let textRangeData = context.textProvider.updateRangeText() {
            // Configure the text animators
            renderLayer.start = textRangeData.start
            renderLayer.end = textRangeData.end
            renderLayer.textRangeUnit = textRangeData.rangeUnit
            renderLayer.selectedRangeOpacity = textRangeData.rangeOpacity
            renderLayer.textRangeFont = textRangeData.rangeFont
            renderLayer.textRangeColor = textRangeData.rangeColor
        } else {
            // Configure the text animators
            renderLayer.start = start
            renderLayer.end = end
            if let newEnd = end, newEnd > 0 {
                if start == nil {
                    renderLayer.start = 0
                }
            }
            renderLayer.textRangeUnit = textRangeUnit
            renderLayer.selectedRangeOpacity = selectedRangeOpacity
            renderLayer.textRangeColor = rootNode?.textOutputNode.fillColor
        }
        
        if let worldSpace = context.textProvider.updateWorldSpacing(CGFloat(text.tracking)) {
            renderLayer.tracking = worldSpace
        } else {
            renderLayer.tracking = (CGFloat(text.fontSize) * CGFloat(text.tracking)) / 1000
        }
                
        if let fillColor = context.textProvider.updateTextFillColor(text.fillColorData?.cgColorValue) {
            renderLayer.fillColor = fillColor
        } else if let fillColor = text.fillColorData?.cgColorValue {
            renderLayer.fillColor = fillColor
        } else if let fillColor = rootNode?.textOutputNode.fillColor {
            renderLayer.fillColor = fillColor
        } else {
            renderLayer.fillColor = nil
        }
        
        if let underLine = context.textProvider.updateShowUnderLine() {
            renderLayer.showUnderLine = underLine
        } else {
            renderLayer.showUnderLine = false
        }
//        if let backColor = context.textProvider.updateTextBackgroundColor() {
//            renderLayer.backColor = backColor.color
//        } else {
//            renderLayer.backColor = nil
//        }
        
        var strokeColor:CGColor?
        if let newStrokeColor = context.textProvider.updateTextStrokeColor(text.strokeColorData?.cgColorValue) {
            strokeColor = newStrokeColor
        } else if let newStrokeColor = rootNode?.textOutputNode.strokeColor {
            strokeColor = newStrokeColor
        } else {
            strokeColor = text.strokeColorData?.cgColorValue
        }
        
        renderLayer.strokeColor = strokeColor
        
        var strokeWidth:CGFloat = 0
        if let newStrokeWidth = context.textProvider.updateTextStrokeWidth(text.strokeWidth) {
            strokeWidth = newStrokeWidth
        } else if let newStrokeWidth = rootNode?.textOutputNode.strokeWidth {
            strokeWidth = newStrokeWidth + 3
        } else {
            strokeWidth = CGFloat(text.strokeWidth ?? 0)
        }
        
        renderLayer.strokeWidth = strokeWidth
        
        renderLayer.strokeOnTop = text.strokeOverFill ?? false
        
        renderLayer.preferredSize = text.textFrameSize?.sizeValue
        // Apply the custom contents scale for this layer if it was provided
        if
          let contentsScaleProvider = context.textProvider as? TextContentsScaleProvider,
          let contentsScale = contentsScaleProvider.contentsScale(for: textAnimationContext.currentKeypath)
        {
          renderLayer.contentsScale = contentsScale
        }

        renderLayer.sizeToFit()
        
        renderLayer.transform = CATransform3DIdentity
        renderLayer.position = text.textFramePosition?.pointValue ?? .zero
    }
    
    // MARK: Private
    
    private let textLayerModel: TextLayerModel
    private let renderLayer = CoreTextRenderLayer()
    private let rootNode: TextAnimatorNode?
    
    private func setupSublayers() {
        // Place the text render layer in an additional container
        //  - Direct sublayers of a `BaseCompositionLayer` always fill the bounds
        //    of their superlayer -- so this container will be the bounds of self,
        //    and the text render layer can be positioned anywhere.
        let textContainerLayer = CALayer()
        textContainerLayer.addSublayer(renderLayer)
        addSublayer(textContainerLayer)
    }
    
}
