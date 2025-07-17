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

  var textAlignment: NSTextAlignment {
    switch self {
    case .left:
      .left
    case .right:
      .right
    case .center:
      .center
    case .justifyLastLineLeft, .justifyLastLineRight, .justifyLastLineCenter, .justifyLastLineFull:
      .justified
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
    case .justifyLastLineLeft, .justifyLastLineRight, .justifyLastLineCenter, .justifyLastLineFull:
      .justified
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
        contentsLayer.addSublayer(backgroundLayer)
        contentsLayer.addSublayer(self.textLayer)
//        self.textLayer.frame = CGRect(x: 0, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        
        backgroundLayer.fillColor = UIColor.clear.cgColor   // 初始无色
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
    private let backgroundLayer = CAShapeLayer()
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
        print("lintheig===>\(textLayer.lineHeight)===>wosdpace:\(tracking)")
//        if let backColor = textProvider.updateTextBackgroundColor() {
//            textLayer.backColor = backColor.color
//        } else {
//            textLayer.backColor = nil
//        }
        
        
        textLayer.tracking = tracking
        if let textRangeData = textProvider.updateRangeText() {
            // Configure the text animators
            textLayer.start = textRangeData.start
            textLayer.end = textRangeData.end
            textLayer.textRangeUnit = textRangeData.rangeUnit
            textLayer.selectedRangeOpacity = textRangeData.rangeOpacity
            textLayer.textRangeFont = textRangeData.rangeFont
            textLayer.textRangeColor = textRangeData.rangeColor
            textLayer.textRangeStrokeColor = textRangeData.strokeColor
            textLayer.textRangeStrokeWidth = (textRangeData.strokeFineness ?? 0) * 4
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
        
        // ====== 新增：阴影处理 ======
        if let shadowModel = textProvider.updateTextShadowColor() {
            // 阴影颜色
            textLayer.textShadowColor = shadowModel.shadowColor
            // 阴影透明度（Core Animation 使用 0~1 的 Float）
            if let opa = shadowModel.shadowOpacity {
                textLayer.textShadowOpacity = CGFloat(opa)
            } else {
                textLayer.textShadowOpacity = 1.0
            }
            // 模糊半径
            if let blur = shadowModel.shadowBlur {
                textLayer.textShadowBlur = 3
            } else {
                textLayer.textShadowBlur = 3   // 与 Android 默认保持一致
            }
            // 偏移量：由距离 + 角度计算，角度制 → 弧度制
            if let distance = shadowModel.shadowDistance,
               let angle    = shadowModel.shadowAngle {
                let distPx = CGFloat(distance)
                let rad = CGFloat(angle) * .pi / 180.0
                var dx  = distPx * cos(rad)
                var dy  = distPx * sin(rad)
                // 若几何坐标翻转，则反向 y
                if textLayer.isGeometryFlipped { dy = -dy }

                textLayer.textShadowOffset = CGSize(width: dx, height: dy)
            } else {
                textLayer.textShadowOffset = .zero
            }
            // 关闭剪裁，阴影才能显示完整
            textLayer.masksToBounds = false
        } else {
            // 未配置阴影时将透明度归零即可
            textLayer.textShadowOpacity = 0
        }
        
        textLayer.preferredSize = text.textFrameSize?.sizeValue //设置固定宽高
//        textLayer.strokeOnTop = text.strokeOverFill ?? false //使用默认false，设置外描边
        textLayer.strokeWidth = strokeWidth * 4
        textLayer.strokeColor = strokeColor
        textLayer.sizeToFit()
        
        textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
        textLayer.transform = CATransform3DIdentity
        textLayer.position = text.textFramePosition?.pointValue ?? CGPoint.zero
        textLayer.transform = matrix
        updateBackground()
    }
    
    // MARK: - Background

    private func updateBackground() {
        // 1) 如果没有背景色，直接隐藏
        guard let bgModel = textProvider.updateTextBackgroundColor() else {
            backgroundLayer.isHidden = true
            return
        }
        guard let font = textLayer.font, let attributedString = textLayer.attributedString else {
            backgroundLayer.isHidden = true
            return
        }
        backgroundLayer.isHidden = false
        backgroundLayer.fillColor = bgModel.color
        
        // 2) 计算实际文字内容的尺寸
        let textSize = calculateTextSize(attributedString: attributedString)
        // 2) 一个字的“参考尺寸”——用字体行高近似
        
        let glyphSize = CTFontGetCapHeight(font)
        
        // 3) 计算需要扩展的像素
        let glypw = (bgModel.enlarge?.x ?? 0) * glyphSize     // 左右各扩 dx
        let glyph = (bgModel.enlarge?.y ?? 0) * glyphSize     // 上下各扩 dy
        
        // 3) 取文字排版原始 bounds
        //        let tBounds = textLayer.bounds     // origin 一直是 .zero
        
        // 5) 生成背景大小
        let bgSize = CGSize(width: textSize.width + glypw * 2,
                            height: textSize.height + glyph * 2)
        backgroundLayer.bounds = CGRect(origin: .zero, size: bgSize)
        
        
        // 6) 计算偏移量 (0.5表示居中)
        let offsetXValue = (bgModel.offset?.x ?? 0.5)
        let offsetYValue = (bgModel.offset?.y ?? 0.5)
        
        let offsetX = (offsetXValue - 0.5) * textSize.width * 2
        // 注意这里符号取反，使y=0时向上偏移，y=1时向下偏移
        let offsetY = -(offsetYValue - 0.5) * textSize.height * 2
        print("offsetX:\(offsetX)offsetYsss:\(offsetY)")
        // 7) 计算背景的中心位置
//        let textCenter = calculateTextCenter(textSize: textSize)
        backgroundLayer.position = CGPoint(
            x: textLayer.position.x + offsetX,
            y: textLayer.position.y + offsetY
        )
        
        backgroundLayer.transform = textLayer.transform
        
        // 8) 设置圆角
        let cornerRadius = bgSize.height * (bgModel.radius ?? 0) * 0.5
        let rectPath = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
        backgroundLayer.path = rectPath
        //         // 5) 跟随文字的位置 / 变换
        //         backgroundLayer.position  = textLayer.position
        ////         backgroundLayer.transform = textLayer.transform
        //        backgroundLayer.transform = CATransform3DIdentity   // ← 保持 1:1
        //        // 关键：给 path
        //        let rectPath = UIBezierPath(roundedRect: backgroundLayer.bounds,cornerRadius: bgSize.height * (bgModel.radius ?? 0)).cgPath
        //        backgroundLayer.path = rectPath
    }
    
    // 计算文字内容的实际尺寸
    private func calculateTextSize(attributedString: NSAttributedString) -> CGSize {
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: attributedString.length),
            nil,
            CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            nil)
    }
    
    
    // 计算文字内容的中心位置
    private func calculateTextCenter(textSize: CGSize) -> CGPoint {
        // 根据textLayer的对齐方式计算文字内容的中心位置
        let alignment = textLayer.alignment
        let layerBounds = textLayer.bounds
        
        var centerX: CGFloat
        switch alignment {
        case .left:
            centerX = textSize.width / 2
        case .right:
            centerX = layerBounds.width - textSize.width / 2
        case .center, _:
            centerX = layerBounds.width / 2
        }
        
        // 垂直居中
        let centerY = layerBounds.height / 2
        
        return CGPoint(x: centerX, y: centerY)
    }
    override func updateRenderScale() {
        super.updateRenderScale()
        textLayer.contentsScale = renderScale
    }
}
