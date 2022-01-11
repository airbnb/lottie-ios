// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Sets up an `AnimationLayer` / `CALayer` hierarchy in this layer,
  /// using the given list of layers.
  func setupLayerHierarchy(
    for layers: [LayerModel],
    context: LayerContext)
  {
    // An `Animation`'s `LayerModel`s are listed from front to back,
    // but `CALayer.sublayers` are listed from back to front.
    // We reverse the layer ordering to match what Core Animation expects.
    // The final view hierarchy must display the layers in this exact order.
    let layersInZAxisOrder = layers.reversed()

    let layersByIndex = Dictionary(grouping: layersInZAxisOrder, by: \.index)
      .compactMapValues(\.first)

    /// Layers specify a `parent` layer. Child layers inherit the `transform` of their parent.
    ///  - We can't add the child as a sublayer of the parent `CALayer`, since that would
    ///    break the ordering specified in `layersInZAxisOrder`.
    ///  - Instead, we create an invisible `TransformLayer` to handle the parent
    ///    transform animations, and add the child layer to that `TransformLayer`.
    func setupParentTransformLayers(
      for layerModel: LayerModel,
      name: (LayerModel) -> String)
      -> TransformLayer?
    {
      guard
        let parentIndex = layerModel.parent,
        let parentLayerModel = layersByIndex[parentIndex]
      else { return nil }

      let parentLayer = TransformLayer(layerModel: parentLayerModel)
      parentLayer.name = name(parentLayerModel)

      if let nextParent = setupParentTransformLayers(for: parentLayerModel, name: name) {
        nextParent.addSublayer(parentLayer)
      } else {
        addSublayer(parentLayer)
      }

      return parentLayer
    }

    // Create an `AnimationLayer` for each `LayerModel`
    for layerModel in layersInZAxisOrder {
      guard let layer = layerModel.makeAnimationLayer(context: context) else {
        continue
      }

      // If this layer has a `parent`, we create an invisible `TransformLayer`
      // to handle displaying / animating the parent transform.
      let parentTransformLayer = setupParentTransformLayers(
        for: layerModel,
        name: { parentLayerModel in
          "\(layerModel.name) (parent, \(parentLayerModel.name))"
        })

      if let parentTransformLayer = parentTransformLayer {
        parentTransformLayer.addSublayer(layer)
      } else {
        addSublayer(layer)
      }
    }
  }

}
