// Created by Cal Stephens on 12/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {
  /// Adds base animations for the given `LayerModel` subclass to this `CALayer`
  func addBaseAnimations(
    for baseLayerModel: LayerModel,
    context: LayerAnimationContext)
  {
    addAnimations(for: baseLayerModel.transform, context: context)

    // TODO: Implement other behaviors in the base `LayerModel` type
  }
}
