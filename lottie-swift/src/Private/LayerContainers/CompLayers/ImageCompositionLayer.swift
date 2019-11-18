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
  
  // Image currently can't be animated or dynamicaly changed for layer in AE,
  // so changing image property will lead to nothing after layer was displayed
  var image: CGImage? = nil
  var shouldUpdateImage = true
  
  let imageReferenceID: String
  
  init(imageLayer: ImageLayerModel, size: CGSize) {
    self.imageReferenceID = imageLayer.referenceID
    super.init(layer: imageLayer, size: size)
    contentsLayer.masksToBounds = true
    contentsLayer.contentsGravity = CALayerContentsGravity.resize
  }
  
  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? ImageCompositionLayer else {
      fatalError("init(layer:) Wrong Layer Class")
    }
    self.imageReferenceID = layer.imageReferenceID
    self.image = nil
    super.init(layer: layer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    if shouldUpdateImage {
        contentsLayer.contents = image
        shouldUpdateImage = false
    }
  }
  
}
