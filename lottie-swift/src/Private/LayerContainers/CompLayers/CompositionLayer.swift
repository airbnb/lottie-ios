//
//  LayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import QuartzCore

/**
 The base class for a child layer of CompositionContainer
 */
class CompositionLayer: CALayer, KeypathSearchable {

    private struct AssociatedPropertiesKeys {
        static var renderScale: CGFloat = 1
        static var matteLayer: CompositionLayer? = nil
        static var layerDelegate: CompositionLayerDelegate? = nil
        static var transformNode: LayerTransformNode? = nil
        static var contentsLayer: CALayer = CALayer()
        static var maskLayer: MaskContainerLayer? = nil
        static var matteType: MatteType? = nil
        static var keypathName: String = ""
        static var childKeypaths: [KeypathSearchable] = []
        static var inFrame: CGFloat = 0
        static var outFrame: CGFloat = 0
        static var timeStretch: CGFloat = 0
        static var startFrame: CGFloat = 0
    }

    var layerDelegate: CompositionLayerDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.layerDelegate) as? CompositionLayerDelegate
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.layerDelegate,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var renderScale: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderScale
            ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.renderScale,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            self.updateRenderScale()
        }
    }

    var matteLayer: CompositionLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.matteLayer) as? CompositionLayer
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.matteLayer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            if let matte = matteLayer {
                if let type = matteType, type == .invert {
                    mask = InvertedMatteLayer(inputMatte: matte)
                } else {
                    mask = matte
                }
            } else {
                mask = nil
            }
        }
    }

    var transformNode: LayerTransformNode {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.transformNode
                ) as? LayerTransformNode else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.transformNode,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    var contentsLayer: CALayer {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.contentsLayer
                ) as? CALayer else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.contentsLayer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    var maskLayer: MaskContainerLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.maskLayer) as? MaskContainerLayer
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.maskLayer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    var matteType: MatteType? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.matteType) as? MatteType
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.matteType,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var keypathName: String {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.keypathName
                ) as? String else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.keypathName,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    final var childKeypaths: [KeypathSearchable] {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.childKeypaths
                ) as? [KeypathSearchable] else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.childKeypaths,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var keypathProperties: [String : AnyNodeProperty] {
        return [:]
    }

    var keypathLayer: CALayer? {
        return contentsLayer
    }

    private(set) var inFrame: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.inFrame
                ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.inFrame,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    private(set) var outFrame: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.outFrame
                ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.outFrame,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    private(set) var startFrame: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.startFrame
                ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.startFrame,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    private(set) var timeStretch: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.timeStretch
                ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.timeStretch,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(layer: LayerModel, size: CGSize) {

        super.init()
        self.inFrame = layer.inFrame.cgFloat
        self.outFrame = layer.outFrame.cgFloat
        self.timeStretch = layer.timeStretch.cgFloat
        self.startFrame = layer.startTime.cgFloat
        self.transformNode = LayerTransformNode(transform: layer.transform)
        if let masks = layer.masks {
            maskLayer = MaskContainerLayer(masks: masks)
        } else {
            maskLayer = nil
        }
        self.matteType = layer.matte
        self.childKeypaths = [transformNode.transformProperties]
        self.contentsLayer = CALayer()
        self.keypathName = layer.name
        self.anchorPoint = .zero
        self.actions = [
            "opacity" : NSNull(),
            "transform" : NSNull(),
            "bounds" : NSNull(),
            "anchorPoint" : NSNull(),
            "sublayerTransform" : NSNull()
        ]

        contentsLayer.anchorPoint = .zero
        contentsLayer.bounds = CGRect(origin: .zero, size: size)
        contentsLayer.actions = [
            "opacity" : NSNull(),
            "transform" : NSNull(),
            "bounds" : NSNull(),
            "anchorPoint" : NSNull(),
            "sublayerTransform" : NSNull(),
            "hidden" : NSNull()
        ]
        addSublayer(contentsLayer)

        if let maskLayer = maskLayer {
            contentsLayer.mask = maskLayer
        }
    }

    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? CompositionLayer else {
            fatalError("Wrong Layer Class")
        }

        super.init(layer: layer)
        self.inFrame = layer.inFrame
        self.outFrame = layer.outFrame
        self.timeStretch = layer.timeStretch
        self.startFrame = layer.startFrame
        self.transformNode = layer.transformNode
        self.matteType = layer.matteType
        self.childKeypaths = [transformNode.transformProperties]
        self.maskLayer = nil
        self.renderScale = 1
        self.contentsLayer = CALayer()
        self.layerDelegate = nil
        self.matteLayer = nil
        self.keypathName = layer.keypathName
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    final func displayWithFrame(frame: CGFloat, forceUpdates: Bool) {
        transformNode.updateTree(frame, forceUpdates: forceUpdates)
        let layerVisible = frame.isInRangeOrEqual(inFrame, outFrame)
        /// Only update contents if current time is within the layers time bounds.
        if layerVisible {
            displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
            maskLayer?.updateWithFrame(frame: frame, forceUpdates: forceUpdates)
        }
        contentsLayer.transform = transformNode.globalTransform
        contentsLayer.opacity = transformNode.opacity
        contentsLayer.isHidden = !layerVisible
        layerDelegate?.frameUpdated(frame: frame)
    }

    func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        /// To be overridden by subclass
    }

    // MARK: Keypath Searchable

    func updateRenderScale() {
        self.contentsScale = self.renderScale
    }
}

protocol CompositionLayerDelegate: class {
    func frameUpdated(frame: CGFloat)
}

