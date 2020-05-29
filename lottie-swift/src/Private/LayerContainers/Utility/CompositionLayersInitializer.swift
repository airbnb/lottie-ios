//
//  CompositionLayersInitializer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import CoreGraphics
import QuartzCore

extension Array where Element == LayerModel {
  
  func initializeCompositionLayers(assetLibrary: AssetLibrary?,
                                   layerImageProvider: LayerImageProvider,
                                   layerTextProvider: LayerTextProvider,
                                   layerVideoProvider: LayerVideoProvider,
                                   frameRate: CGFloat, fonts: FontList?) -> [CALayer & Composition] {
    var compositionLayers = [CALayer & Composition]()
    var layerMap = [Int : CALayer & Composition]()
    
    /// Organize the assets into a dictionary of [ID : ImageAsset]
    var childLayers = [LayerModel]()
    
    for layer in self {
        if layer.parent != 0,
           (layer.transform.position?.keyframes.first { $0.value.z != 0 }) != nil {
            self.first { $0.index == layer.parent }?.flatHierarchy = false
        }
    }
    
    for layer in self {
      if layer.hidden == true {
        let genericLayer = NullCompositionLayer(layer: layer)
        compositionLayers.append(genericLayer)
        layerMap[layer.index] = genericLayer
      } else if let shapeLayer = layer as? ShapeLayerModel {
        if (shapeLayer.transform.position?.keyframes.first { $0.value.z != 0 }) == nil {
            let shapeContainer = ShapeCompositionLayer(shapeLayer: shapeLayer)
            compositionLayers.append(shapeContainer)
            layerMap[layer.index] = shapeContainer
        } else {
            let shapeContainer = ShapeTransformCompositionLayer(shapeLayer: shapeLayer)
            compositionLayers.append(shapeContainer)
            layerMap[layer.index] = shapeContainer
        }
      } else if let solidLayer = layer as? SolidLayerModel {
        let solidContainer = SolidCompositionLayer(solid: solidLayer)
        compositionLayers.append(solidContainer)
        layerMap[layer.index] = solidContainer
      } else if let precompLayer = layer as? PreCompLayerModel,
        let assetLibrary = assetLibrary,
        let precompAsset = assetLibrary.precompAssets[precompLayer.referenceID] {
        precompLayer.flatHierarchy = false
        let precompContainer = PreCompositionLayer(precomp: precompLayer,
                                                   asset: precompAsset,
                                                   layerImageProvider: layerImageProvider,
                                                   layerTextProvider: layerTextProvider,
                                                   layerVideoProvider: layerVideoProvider,
                                                   assetLibrary: assetLibrary,
                                                   frameRate: frameRate)
        compositionLayers.append(precompContainer)
        layerMap[layer.index] = precompContainer
      } else if let imageLayer = layer as? ImageLayerModel,
        let assetLibrary = assetLibrary,
        let imageAsset = assetLibrary.imageAssets[imageLayer.referenceID] {
        let imageContainer = ImageCompositionLayer(imageLayer: imageLayer, size: CGSize(width: imageAsset.width, height: imageAsset.height))
        compositionLayers.append(imageContainer)
        layerMap[layer.index] = imageContainer
      } else if let textLayer = layer as? TextLayerModel {
        let textContainer = TextCompositionLayer(textLayer: textLayer, textProvider: layerTextProvider.textProvider, fonts: fonts)
        compositionLayers.append(textContainer)
        layerMap[layer.index] = textContainer
    } else if let videoLayer = layer as? VideoLayerModel {
        let videoContainer = VideoCompositionLayer(videoModel: videoLayer, videoProvider: layerVideoProvider.videoProvider)
        compositionLayers.append(videoContainer)
        layerMap[layer.index] = videoContainer
      } else {
        let genericLayer = NullCompositionLayer(layer: layer)
        compositionLayers.append(genericLayer)
        layerMap[layer.index] = genericLayer
      }
      if layer.parent != nil {
        childLayers.append(layer)
      }
    }
    
    /// Now link children with their parents
    for layerModel in childLayers {
      if let parentID = layerModel.parent {
        let childLayer = layerMap[layerModel.index]
        let parentLayer = layerMap[parentID]
        childLayer?.transformNode.parentNode = parentLayer?.transformNode
      }
    }
    
    return compositionLayers
  }
  
}
