// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - GradientRenderLayer

/// A `CAGradientLayer` subclass used to render a gradient _outside_ the normal layer bounds
///
///  - `GradientFill.startPoint` and `GradientFill.endPoint` are expressed
///    with respect to the `bounds` of the `ShapeItemLayer`.
///
///  - The gradient itself is supposed to be rendered infinitely in all directions
///    (e.g. including outside of `bounds`). This is because `ShapeItemLayer` paths
///    don't necessarily sit within the layer's `bounds`.
///
///  - To support this, `GradientRenderLayer` tracks a `gradientReferenceBounds`
///    that `startPoint` / `endPoint` are calculated relative to.
///    The _actual_ `bounds` of this layer is padded by a large amount so that
///    the gradient can be drawn outside of the `gradientReferenceBounds`.
///
final class GradientRenderLayer: CAGradientLayer {

  // MARK: Internal

  /// The reference bounds within this layer that the gradient's
  /// `startPoint` and `endPoint` should be calculated relative to
  var gradientReferenceBounds: CGRect = .zero {
    didSet {
      if oldValue != gradientReferenceBounds {
        updateLayout()
      }
    }
  }

  /// Converts the given `CGPoint` within `gradientReferenceBounds`
  /// to a percentage value relative to the full `bounds` of this layer
  ///  - This converts absolute `startPoint` and `endPoint` values into
  ///    the percent-based values expected by Core Animation,
  ///    with respect to the custom bounds geometry used by this layer type.
  func percentBasedPointInBounds(from referencePoint: CGPoint) -> CGPoint {
    guard bounds.width > 0, bounds.height > 0 else {
      LottieLogger.shared.assertionFailure("Size must be non-zero before an animation can be played")
      return .zero
    }

    let pointInBounds = CGPoint(
      x: referencePoint.x + gradientPadding,
      y: referencePoint.y + gradientPadding)

    return CGPoint(
      x: CGFloat(pointInBounds.x) / bounds.width,
      y: CGFloat(pointInBounds.y) / bounds.height)
  }

  // MARK: Private

  /// Extra padding around the `gradientReferenceBounds` where the gradient is also rendered
  ///  - This specific value is arbitrary and can be increased if necessary.
  ///    Theoretically this should be "infinite", to match the behavior of
  ///    `CGContext.drawLinearGradient` with `[.drawsAfterEndLocation, .drawsBeforeStartLocation]`.
  private let gradientPadding: CGFloat = 2_000

  private func updateLayout() {
    anchorPoint = .zero

    bounds = CGRect(
      x: gradientReferenceBounds.origin.x,
      y: gradientReferenceBounds.origin.y,
      width: gradientPadding + gradientReferenceBounds.width + gradientPadding,
      height: gradientPadding + gradientReferenceBounds.height + gradientPadding)

    transform = CATransform3DMakeTranslation(
      -gradientPadding,
      -gradientPadding,
      0)
  }

}

// MARK: CustomLayoutLayer

extension GradientRenderLayer: CustomLayoutLayer {
  func layout(superlayerBounds: CGRect) {
    gradientReferenceBounds = superlayerBounds
  }
}
