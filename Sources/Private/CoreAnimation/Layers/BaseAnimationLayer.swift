// Created by Cal Stephens on 1/27/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

#if os(watchOS)
import CAShim
#else
import QuartzCore
#endif

// MARK: - BaseAnimationLayer

/// A base `CALayer` that manages the frame and animations
/// of its `sublayers` and `mask`
class BaseAnimationLayer: CALayer, AnimationLayer {

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in managedSublayers {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  func setupAnimations(context: LayerAnimationContext) throws {
    // Only set up animations for sublayers here, not MaskCompositionLayer masks.
    // MaskCompositionLayer animations must be set up separately with the parent's context
    // (without precomp time remapping), since mask keyframes are defined
    // in the parent's global timeline. See BaseCompositionLayer.setupLayerAnimations.
    for childAnimationLayer in sublayers ?? [] {
      try (childAnimationLayer as? AnimationLayer)?.setupAnimations(context: context)
    }

    // Set up animations for non-MaskCompositionLayer masks (e.g. alpha matte masks
    // created in CALayer+setupLayerHierarchy.swift). These receive the same context
    // as the layer they're masking. MaskCompositionLayer is excluded here because it
    // is handled explicitly in BaseCompositionLayer.setupLayerAnimations with the
    // parent's non-remapped context.
    if let maskAnimationLayer = mask as? AnimationLayer, !(mask is MaskCompositionLayer) {
      try maskAnimationLayer.setupAnimations(context: context)
    }
  }

  // MARK: Private

  /// All of the sublayers managed by this container
  private var managedSublayers: [CALayer] {
    (sublayers ?? []) + [mask].compactMap { $0 }
  }

}
