// Created by Cal Stephens on 10/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ExpandedAnimationLayer

/// A `BaseAnimationLayer` subclass that renders its background color
/// as if the layer is infinitely large, without affecting its bounds
/// or the bounds of its sublayers
final class InfiniteOpaqueAnimationLayer: BaseAnimationLayer {

  override init() {
    super.init()
    addSublayer(additionalPaddingLayer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSublayers() {
    super.layoutSublayers()

    masksToBounds = false
    additionalPaddingLayer.backgroundColor = backgroundColor

    // Scale `additionalPaddingLayer` to be larger than this layer
    // by `additionalPadding` at each size, and centered at the center
    // of this layer. Since `additionalPadding` is very large, this has
    // the affect of making `additionalPaddingLayer` appear infinite.
    let scaleRatioX = (bounds.width + (additionalPadding * 2)) / bounds.width
    let scaleRatioY = (bounds.height + (additionalPadding * 2)) / bounds.height

    additionalPaddingLayer.transform = CATransform3DScale(
      CATransform3DMakeTranslation(-additionalPadding, -additionalPadding, 0),
      scaleRatioX,
      scaleRatioY,
      1)
  }

  private let additionalPaddingLayer = CALayer()

  /// Additional padding around `self.bounds` that should be filled in with `self.backgroundColor`
  ///  - This specific value is arbitrary and can be increased if necessary.
  private let additionalPadding: CGFloat = 10_000.0

}
