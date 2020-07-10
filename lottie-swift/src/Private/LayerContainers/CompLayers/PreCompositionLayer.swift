//
//  PreCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import QuartzCore

final class PreCompositionLayer: CompositionLayer {

    private struct AssociatedPropertiesKeys {
        static var remappingNode: NodeProperty<Vector1D>? = nil
        static var animationLayers: [CompositionLayer] = []
    }

    var remappingNode: NodeProperty<Vector1D>? {
        get {
            return objc_getAssociatedObject(self, &AssociatedPropertiesKeys.remappingNode) as? NodeProperty<Vector1D>
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.remappingNode,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    fileprivate var animationLayers: [CompositionLayer] {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.animationLayers
            ) as? [CompositionLayer] else { fatalError("No obj found") }
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

    let frameRate: CGFloat

    init(precomp: PreCompLayerModel,
         asset: PrecompAsset,
         layerImageProvider: LayerImageProvider,
         textProvider: AnimationTextProvider,
         assetLibrary: AssetLibrary?,
         frameRate: CGFloat) {

        self.frameRate = frameRate
        super.init(layer: precomp, size: CGSize(width: precomp.width, height: precomp.height))

        self.animationLayers = []
        if let keyframes = precomp.timeRemapping?.keyframes {
            self.remappingNode = NodeProperty(provider: KeyframeInterpolator(keyframes: keyframes))
        } else {
            self.remappingNode = nil
        }

        contentsLayer.masksToBounds = true
        contentsLayer.bounds = CGRect(origin: .zero, size: CGSize(width: precomp.width, height: precomp.height))

        let layers = asset.layers.initializeCompositionLayers(assetLibrary: assetLibrary, layerImageProvider: layerImageProvider, textProvider: textProvider, frameRate: frameRate)

        var imageLayers = [ImageCompositionLayer]()

        var mattedLayer: CompositionLayer? = nil

        for layer in layers.reversed() {
            layer.bounds = bounds
            animationLayers.append(layer)
            if let imageLayer = layer as? ImageCompositionLayer {
                imageLayers.append(imageLayer)
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
            contentsLayer.addSublayer(layer)
        }

        self.childKeypaths.append(contentsOf: layers)

        layerImageProvider.addImageLayers(imageLayers)
    }

    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? PreCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        self.frameRate = layer.frameRate

        super.init(layer: layer)
        self.remappingNode = nil
        self.animationLayers = []
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        let localFrame: CGFloat
        if let remappingNode = remappingNode {
            remappingNode.update(frame: frame)
            localFrame = remappingNode.value.cgFloatValue * frameRate
        } else {
            localFrame = (frame - startFrame) / timeStretch
        }
        animationLayers.forEach( { $0.displayWithFrame(frame: localFrame, forceUpdates: forceUpdates) })
    }

    override var keypathProperties: [String : AnyNodeProperty] {
        guard let remappingNode = remappingNode else {
            return super.keypathProperties
        }
        return ["Time Remap" : remappingNode]
    }

    override func updateRenderScale() {
        super.updateRenderScale()
        animationLayers.forEach( { $0.renderScale = renderScale } )
    }
}
