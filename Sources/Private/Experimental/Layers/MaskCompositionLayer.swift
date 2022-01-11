// Created by Cal Stephens on 1/6/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - MaskCompositionLayer

/// The CALayer type responsible for rendering the `Mask` of a `BaseCompositionLayer`
final class MaskCompositionLayer: CALayer {

  // MARK: Lifecycle

  init(masks: [Mask]) {
    maskLayers = masks.map(MaskLayer.init(mask:))
    super.init()

    for maskLayer in maskLayers {
      addSublayer(maskLayer)
    }
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

    maskLayers = typedLayer.maskLayers
    super.init(layer: typedLayer)
  }

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let maskLayers: [MaskLayer]

}

// MARK: AnimationLayer

extension MaskCompositionLayer: AnimationLayer {
  func setupAnimations(context: LayerAnimationContext) {
    for maskLayer in maskLayers {
      maskLayer.setupAnimations(context: context)
    }
  }
}

// MARK: - MaskLayer

extension MaskCompositionLayer {
  final class MaskLayer: CAShapeLayer {

    // MARK: Lifecycle

    init(mask: Mask) {
      maskModel = mask
      super.init()
      fillColor = .rgb(0, 0, 0)
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

      maskModel = typedLayer.maskModel
      super.init(layer: typedLayer)
    }

    // MARK: Private

    private let maskModel: Mask

  }
}

// MARK: - MaskCompositionLayer.MaskLayer + AnimationLayer

extension MaskCompositionLayer.MaskLayer: AnimationLayer {
  func setupAnimations(context: LayerAnimationContext) {
    addAnimations(for: maskModel.shape, context: context)
  }
}
