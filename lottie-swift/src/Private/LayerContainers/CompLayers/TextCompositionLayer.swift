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
import UIKit

class DisabledTextLayer: CATextLayer {
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

class TextCompositionLayer: CompositionLayer {

    public var compositionSize = CGSize(width: 1080, height: 1920)
    public var isTextWrapped = true

    private var textNodeProperties = TextNodeProperties(attributedString: NSAttributedString(string: ""))

    let rootNode: TextAnimatorNode?
    let textDocument: KeyframeInterpolator<TextDocument>?

    let textLayer: DisabledTextLayer = DisabledTextLayer()

    init(textLayer: TextLayerModel) {
        var rootNode: TextAnimatorNode?
        for animator in textLayer.animators {
            rootNode = TextAnimatorNode(parentNode: rootNode, textAnimator: animator)
        }
        self.rootNode = rootNode
        self.textDocument = KeyframeInterpolator(keyframes: textLayer.text.keyframes)
        super.init(layer: textLayer, size: .zero)
        contentsLayer.addSublayer(self.textLayer)
        self.textLayer.masksToBounds = false
        self.childKeypaths.append(textNodeProperties)
        print(self.childKeypaths)
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

        if let attributedString = attributedString {
            updateContentsWithFrame(frame: frame, attributedString: attributedString, defaultAttributes: attributes)
            return
        }

        let attributedString = NSAttributedString(string: text.text, attributes: attributes )
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                CFRange(location: 0,length: 0),
                                                                nil,
                                                                CGSize(width: compositionSize.width,
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
        textLayer.isWrapped = isTextWrapped
    }

    private var attributedString: NSAttributedString? {
        guard let textProperties = self.nodeProperties(for: AnimationKeypath(keypath: "*.Text.AttributedString")),
            let attributedStringProperty = textProperties.first?.valueProvider as? AttributedStringValueProvider else { return nil }
        return attributedStringProperty.attributedString.string
    }

    private func updateContentsWithFrame(frame: CGFloat, attributedString: NSAttributedString, defaultAttributes: [NSAttributedString.Key : Any]? = nil) {

        var attributes = attributedString.attributes(at: 0, effectiveRange: nil)
        if let defaultAttributes = defaultAttributes {
            attributes.merge(defaultAttributes){(current, _) in current}
        }

        let renderedAttributedString = NSAttributedString(string: attributedString.string, attributes: attributes )

        let matrix = rootNode?.textOutputNode.xform ?? CATransform3DIdentity

        let framesetter = CTFramesetterCreateWithAttributedString(renderedAttributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                CFRange(location: 0,length: 0),
                                                                nil,
                                                                CGSize(width: compositionSize.width,
                                                                       height: CGFloat.greatestFiniteMagnitude),
                                                                nil)

        textLayer.opacity = Float(rootNode?.textOutputNode.opacity ?? 1)
        textLayer.transform = CATransform3DIdentity
        textLayer.frame = CGRect(origin: .zero, size: size)
        textLayer.position = CGPoint.zero
        textLayer.transform = matrix
        textLayer.string = renderedAttributedString
        textLayer.isWrapped = isTextWrapped

        if let paragaphStyle = renderedAttributedString.attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
            switch paragaphStyle.alignment {
            case .left:
                textLayer.anchorPoint = CGPoint(x: 0, y: 1)
            case .right:
                textLayer.anchorPoint = CGPoint(x: 1, y: 1)
            case .center:
                textLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
            default:
                textLayer.anchorPoint = CGPoint(x: 0, y: 1)
            }
        }
    }
}

