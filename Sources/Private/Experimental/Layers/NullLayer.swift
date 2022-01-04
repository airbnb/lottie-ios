// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

/// The CALayer type responsible for rendering `null` `LayerModel`s
final class NullLayer: BaseCompositionLayer {

  /// Null layers shouldn't have any visual effect,
  /// so we shouldn't render apply their transform opacity
  /// (since it would affect the opacity of children).
  override var transformComponentsToAnimate: Set<TransformComponent> {
    .all.subtracting([.opacity])
  }

}
