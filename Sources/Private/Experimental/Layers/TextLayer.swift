// Created by Cal Stephens on 2/9/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

/// The `CALayer` type responsible for rendering `TextLayer`s
final class TextLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(
    textLayerModel: TextLayerModel,
    context: LayerContext)
  {
    self.textLayerModel = textLayerModel
    super.init(layerModel: textLayerModel)
    setupSublayers(context: context)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let typedLayer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    textLayerModel = typedLayer.textLayerModel
    super.init(layer: typedLayer)
  }

  // MARK: Private

  private let textLayerModel: TextLayerModel

  private func setupSublayers(context: LayerContext) {
    // We can't use `CATextLayer`, because it doesn't support enough features we use.
    // Instead, we use the same `CoreTextRenderLayer` (with a custom `draw` implementation)
    // used by the Main Thread rendering engine. This means the Core Animation engine can't
    // _animate_ text properties, but it can display static text without any issues.
    let text = textLayerModel.text.exactlyOneKeyframe.value

    // The Core Animation engine doesn't currently support `TextAnimator`s.
    //  - We could add support for animating the transform-related properties without much trouble.
    //  - We may be able to support animating `fillColor` by getting clever with layer blend modes
    //    or masks (e.g. use `CoreTextRenderLayer` to draw black glyphs, and then fill them in
    //    using a `CAShapeLayer`).
    if !textLayerModel.animators.isEmpty {
      LottieLogger.shared.assertionFailure("""
      The Core Animation rendering engine currently doesn't support text animators.
      """)
    }

    let textLayer = CoreTextRenderLayer()
    textLayer.text = text.text
    textLayer.font = context.fontProvider.fontFor(family: text.fontFamily, size: CGFloat(text.fontSize))

    textLayer.alignment = text.justification.textAlignment
    textLayer.lineHeight = CGFloat(text.lineHeight)
    textLayer.tracking = (CGFloat(text.fontSize) * CGFloat(text.tracking)) / 1000

    textLayer.fillColor = text.fillColorData?.cgColorValue
    textLayer.strokeColor = text.strokeColorData?.cgColorValue
    textLayer.strokeWidth = CGFloat(text.strokeWidth ?? 0)
    textLayer.strokeOnTop = text.strokeOverFill ?? false

    textLayer.preferredSize = text.textFrameSize?.sizeValue
    textLayer.sizeToFit()

    textLayer.transform = CATransform3DIdentity
    textLayer.position = text.textFramePosition?.pointValue ?? .zero

    // Place the text render layer in an additional container
    //  - Direct sublayers of a `BaseCompositionLayer` always fill the bounds
    //    of their superlayer -- so this container will be the bounds of self,
    //    and the text render layer can be positioned anywhere.
    let textContainerLayer = CALayer()
    textContainerLayer.addSublayer(textLayer)
    addSublayer(textContainerLayer)
  }

}
