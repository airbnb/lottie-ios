// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Sets up an `AnimationLayer` / `CALayer` hierarchy in this layer,
  /// using the given list of layers.
  @nonobjc
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
    func makeParentTransformLayer(
      childLayerModel: LayerModel,
      childLayer: CALayer,
      name: (LayerModel) -> String)
      -> CALayer
    {
      guard
        let parentIndex = childLayerModel.parent,
        let parentLayerModel = layersByIndex[parentIndex]
      else { return childLayer }

      let parentLayer = TransformLayer(layerModel: parentLayerModel)
      parentLayer.name = name(parentLayerModel)
      parentLayer.addSublayer(childLayer)

      return makeParentTransformLayer(
        childLayerModel: parentLayerModel,
        childLayer: parentLayer,
        name: name)
    }

    // Create an `AnimationLayer` for each `LayerModel`
    for (layerModel, maskLayerModel) in layersInZAxisOrder.pairedLayersAndMasks() {
      guard let layer = layerModel.makeAnimationLayer(context: context) else {
        continue
      }

      // If this layer has a `parent`, we create an invisible `TransformLayer`
      // to handle displaying / animating the parent transform.
      let parentTransformLayer = makeParentTransformLayer(
        childLayerModel: layerModel,
        childLayer: layer,
        name: { parentLayerModel in
          "\(layerModel.name) (parent, \(parentLayerModel.name))"
        })

      // Create the `mask` layer for this layer, if it has a `MatteType`
      if
        let maskLayerModel = maskLayerModel,
        let maskLayer = maskLayerModel.makeAnimationLayer(context: context)
      {
        let maskParentTransformLayer = makeParentTransformLayer(
          childLayerModel: maskLayerModel,
          childLayer: maskLayer,
          name: { parentLayerModel in
            "\(maskLayerModel.name) (mask of \(layerModel.name)) (parent, \(parentLayerModel.name))"
          })

        // Set up a parent container to host both the layer
        // and its mask in the same coordinate space
        let maskContainer = BaseAnimationLayer()
        maskContainer.name = "\(layerModel.name) (parent, masked)"
        maskContainer.addSublayer(parentTransformLayer)
        maskContainer.mask = maskParentTransformLayer
        addSublayer(maskContainer)
      }

      else {
        addSublayer(parentTransformLayer)
      }
    }
  }

}

extension Collection where Element == LayerModel {
  /// Pairs each `LayerModel` within this array with
  /// a `LayerModel` to use as its mask, if applicable
  /// based on the layer's `MatteType` configuration.
  ///  - Assumes the layers are sorted in z-axis order.
  fileprivate func pairedLayersAndMasks() -> [(layer: LayerModel, mask: LayerModel?)] {
    var layersAndMasks = [(layer: LayerModel, mask: LayerModel?)]()
    var unprocessedLayers = reversed()

    while let layer = unprocessedLayers.popLast() {
      /// If a layer has a `MatteType`, then the next layer will be used as its `mask`
      if
        let matteType = layer.matte,
        matteType != .none,
        let maskLayer = unprocessedLayers.popLast()
      {
        LottieLogger.shared.assert(
          matteType == .add,
          "The Core Animation rendering engine currently only supports `MatteMode.add`.")

        layersAndMasks.append((layer: layer, mask: maskLayer))
      }

      else {
        layersAndMasks.append((layer: layer, mask: nil))
      }
    }

    return layersAndMasks
  }
}
