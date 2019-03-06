//
//  ImageCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore

class ImageCompositionLayer: CompositionLayer {
  
  var image: CGImage? = nil {
    didSet {
      if let image = image {
        contentsLayer.contents = image
      } else {
        contentsLayer.contents = nil
      }
    }
  }
  
  let imageReferenceID: String
  
  init(imageLayer: ImageLayerModel, size: CGSize) {
    self.imageReferenceID = imageLayer.referenceID
    super.init(layer: imageLayer, size: size)
    contentsLayer.masksToBounds = true
    contentsLayer.contentsGravity = kCAGravityResize
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
