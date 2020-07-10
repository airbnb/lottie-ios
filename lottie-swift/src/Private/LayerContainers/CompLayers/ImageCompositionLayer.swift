//
//  ImageCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore

final class ImageCompositionLayer: CompositionLayer {

    private struct AssociatedPropertiesKeys {
        static var image: CGImage? = nil
        static var imageReferenceID: String = ""
    }

    var image: CGImage? {
        get {
            guard let val = objc_getAssociatedObject(self, &AssociatedPropertiesKeys.image) else {
                return nil
            }
            return (val as! CGImage)
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.image,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            if let image = image {
                contentsLayer.contents = image
            } else {
                contentsLayer.contents = nil
            }
        }
    }

    var imageReferenceID: String {
        get {
            guard let val = objc_getAssociatedObject(
                self,
                &AssociatedPropertiesKeys.imageReferenceID
            ) as? String else { fatalError("No obj found") }
            return val
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedPropertiesKeys.imageReferenceID,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(imageLayer: ImageLayerModel, size: CGSize) {
        super.init(layer: imageLayer, size: size)
        self.image = nil
        self.imageReferenceID = imageLayer.referenceID
        contentsLayer.masksToBounds = true
        contentsLayer.contentsGravity = CALayerContentsGravity.resize
    }

    override init(layer: Any) {
        /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
        guard let layer = layer as? ImageCompositionLayer else {
            fatalError("init(layer:) Wrong Layer Class")
        }
        super.init(layer: layer)
        self.imageReferenceID = layer.imageReferenceID
        self.image = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
