//
//  AnimationContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/24/19.
//

import Foundation
import QuartzCore

/**
 The base animation container.
 
 This layer holds a single composition container and allows for animation of
 the currentFrame property.
 */
final class AnimationContainer: CALayer {

    private struct AssociatedPropertiesKeys {
        static var currentFrame: CGFloat = 0
        static var renderScale: CGFloat = 1
        static var respectAnimationFrameRate: Bool = false
        static var animationLayers: ContiguousArray<CompositionLayer> = []
        static var layerImageProvider: LayerImageProvider = LayerImageProvider(imageProvider: BlankImageProvider(), assets: nil)
        static var layerTextProvider: LayerTextProvider = LayerTextProvider(textProvider: DefaultTextProvider())
    }

    /// The animatable Current Frame Property
    var currentFrame: CGFloat {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.currentFrame
            ) as? CGFloat else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.currentFrame,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var imageProvider: AnimationImageProvider {
        get {
            return layerImageProvider.imageProvider
        }
        set {
            layerImageProvider.imageProvider = newValue
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
            animationLayers.forEach({ $0.renderScale = newValue })
        }
    }

    public var respectAnimationFrameRate: Bool {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.respectAnimationFrameRate
            ) as? Bool else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.respectAnimationFrameRate,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var textProvider: AnimationTextProvider {
        get { return layerTextProvider.textProvider }
        set { layerTextProvider.textProvider = newValue }
    }

    var animationLayers: ContiguousArray<CompositionLayer> {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.animationLayers
            ) as? ContiguousArray<CompositionLayer> else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.animationLayers,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }


    fileprivate var layerImageProvider: LayerImageProvider {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.layerImageProvider
            ) as? LayerImageProvider else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.layerImageProvider,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    fileprivate var layerTextProvider: LayerTextProvider {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.layerTextProvider
            ) as? LayerTextProvider else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.layerTextProvider,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(animation: Animation, imageProvider: AnimationImageProvider, textProvider: AnimationTextProvider) {
        super.init()
        self.layerImageProvider = LayerImageProvider(imageProvider: imageProvider, assets: animation.assetLibrary?.imageAssets)
        self.layerTextProvider = LayerTextProvider(textProvider: textProvider)
        self.animationLayers = []
        self.renderScale = 1
        self.respectAnimationFrameRate = false
        bounds = animation.bounds
        let layers = animation.layers.initializeCompositionLayers(assetLibrary: animation.assetLibrary, layerImageProvider: layerImageProvider, textProvider: textProvider, frameRate: CGFloat(animation.framerate))

        var imageLayers = [ImageCompositionLayer]()
        var textLayers = [TextCompositionLayer]()

        var mattedLayer: CompositionLayer? = nil

        for layer in layers.reversed() {
            layer.bounds = bounds
            animationLayers.append(layer)
            if let imageLayer = layer as? ImageCompositionLayer {
                imageLayers.append(imageLayer)
            }
            if let textLayer = layer as? TextCompositionLayer {
                textLayers.append(textLayer)
            }
            if let matte = mattedLayer {
                /// The previous layer requires this layer to be its matte
                matte.matteLayer = layer
                mattedLayer = nil
                continue
            }
            if let matte = layer.matteType,
                (matte == .add || matte == .invert) {
                /// We have a layer that requires a matte.
                mattedLayer = layer
            }
            addSublayer(layer)
        }

        layerImageProvider.addImageLayers(imageLayers)
        layerImageProvider.reloadImages()
        layerTextProvider.addTextLayers(textLayers)
        layerTextProvider.reloadTexts()
        setNeedsDisplay()
    }

    /// For CAAnimation Use
    public override init(layer: Any) {

        super.init(layer: layer)
        self.layerImageProvider = LayerImageProvider(imageProvider: BlankImageProvider(), assets: nil)
        self.layerTextProvider = LayerTextProvider(textProvider: DefaultTextProvider())
        self.animationLayers = []
        self.renderScale = 1
        self.respectAnimationFrameRate = false

        guard let animationLayer = layer as? AnimationContainer else { return }

        self.currentFrame = animationLayer.currentFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadImages() {
        layerImageProvider.reloadImages()
    }

    /// Forces the view to update its drawing.
    func forceDisplayUpdate() {
        animationLayers.forEach( { $0.displayWithFrame(frame: currentFrame, forceUpdates: true) })
    }

    func logHierarchyKeypaths() {
        print("Lottie: Logging Animation Keypaths")
        animationLayers.forEach({ $0.logKeypaths(for: nil) })
    }

    func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
        for layer in animationLayers {
            if let foundProperties = layer.nodeProperties(for: keypath) {
                for property in foundProperties {
                    property.setProvider(provider: valueProvider)
                }
                layer.displayWithFrame(frame: presentation()?.currentFrame ?? currentFrame, forceUpdates: true)
            }
        }
    }

    func getValue(for keypath: AnimationKeypath, atFrame: CGFloat?) -> Any? {
        for layer in animationLayers {
            if let foundProperties = layer.nodeProperties(for: keypath),
                let first = foundProperties.first {
                return first.valueProvider.value(frame: atFrame ?? currentFrame)
            }
        }
        return nil
    }

    func layer(for keypath: AnimationKeypath) -> CALayer? {
        for layer in animationLayers {
            if let foundLayer = layer.layer(for: keypath) {
                return foundLayer
            }
        }
        return nil
    }

    func animatorNodes(for keypath: AnimationKeypath) -> [AnimatorNode]? {
        var results = [AnimatorNode]()
        for layer in animationLayers {
            if let nodes = layer.animatorNodes(for: keypath) {
                results.append(contentsOf: nodes)
            }
        }
        if results.count == 0 {
            return nil
        }
        return results
    }

    // MARK: CALayer Animations

    override public class func needsDisplay(forKey key: String) -> Bool {
        if key == "currentFrame" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override public func action(forKey event: String) -> CAAction? {
        if event == "currentFrame" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.fromValue = self.presentation()?.currentFrame
            return animation
        }
        return super.action(forKey: event)
    }

    public override func display() {
        guard Thread.isMainThread else { return }
        var newFrame: CGFloat = self.presentation()?.currentFrame ?? self.currentFrame
        if respectAnimationFrameRate {
            newFrame = floor(newFrame)
        }
        animationLayers.forEach( { $0.displayWithFrame(frame: newFrame, forceUpdates: false) })
    }

}

fileprivate class BlankImageProvider: AnimationImageProvider {
    func imageForAsset(asset: ImageAsset) -> CGImage? {
        return nil
    }
}
