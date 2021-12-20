// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerConstructing

/// A type that can construct a CALayer to display in a Lottie animation
protocol LayerConstructing {
  func makeLayer(context: LayerContext) -> AnimationLayer
}

/// Context available when constructing an `AnimationLayer`
struct LayerContext {
  let assetLibrary: AssetLibrary?
}

// MARK: - AnimationLayer

/// A type of `CALayer` that can be used in a Lottie animation
protocol AnimationLayer: CALayer {
  /// Instructs this layer to setup its `CAAnimation`s
  /// using the given `LayerAnimationContext`
  func setupAnimations(context: LayerAnimationContext)
}
