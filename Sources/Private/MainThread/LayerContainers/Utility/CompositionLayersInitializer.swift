//
//  CompositionLayersInitializer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import CoreGraphics
import Foundation

extension Array where Element == LayerModel {

  func initializeCompositionLayers(
    assetLibrary: AssetLibrary?,
    layerImageProvider: LayerImageProvider,
    textProvider: AnimationTextProvider,
    fontProvider: AnimationFontProvider,
    frameRate: CGFloat) -> [CompositionLayer]
  {
    var compositionLayers = [CompositionLayer]()
    var layerMap = [Int : CompositionLayer]()

    /// Organize the assets into a dictionary of [ID : ImageAsset]
    var childLayers = [LayerModel]()

    for layer in self {
      if layer.hidden == true {
        let genericLayer = NullCompositionLayer(layer: layer)
        compositionLayers.append(genericLayer)
        layerMap[layer.index] = genericLayer
      } else if let shapeLayer = layer as? ShapeLayerModel {
        let shapeContainer = ShapeCompositionLayer(shapeLayer: shapeLayer)
        compositionLayers.append(shapeContainer)
        layerMap[layer.index] = shapeContainer
      } else if let solidLayer = layer as? SolidLayerModel {
        let solidContainer = SolidCompositionLayer(solid: solidLayer)
        compositionLayers.append(solidContainer)
        layerMap[layer.index] = solidContainer
      } else if
        let precompLayer = layer as? PreCompLayerModel,
        let assetLibrary = assetLibrary,
        let precompAsset = assetLibrary.precompAssets[precompLayer.referenceID]
      {
        let precompContainer = PreCompositionLayer(
          precomp: precompLayer,
          asset: precompAsset,
          layerImageProvider: layerImageProvider,
          textProvider: textProvider,
          fontProvider: fontProvider,
          assetLibrary: assetLibrary,
          frameRate: frameRate)
        compositionLayers.append(precompContainer)
        layerMap[layer.index] = precompContainer
      } else if
        let imageLayer = layer as? ImageLayerModel,
        let assetLibrary = assetLibrary,
        let imageAsset = assetLibrary.imageAssets[imageLayer.referenceID]
      {
        let imageContainer = ImageCompositionLayer(
          imageLayer: imageLayer,
          size: CGSize(width: imageAsset.width, height: imageAsset.height))
        compositionLayers.append(imageContainer)
        layerMap[layer.index] = imageContainer
      } else if let textLayer = layer as? TextLayerModel {
        let textContainer = TextCompositionLayer(textLayer: textLayer, textProvider: textProvider, fontProvider: fontProvider)
        compositionLayers.append(textContainer)
        layerMap[layer.index] = textContainer
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
