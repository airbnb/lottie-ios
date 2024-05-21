// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

#if canImport(QuartzCore)
/// The CALayer type responsible for only rendering the `transform` of a `LayerModel`
final class TransformLayer: BaseCompositionLayer {

  /// `TransformLayer`s don't render any visible content,
  /// they just `transform` their sublayers
  override var renderLayerContents: Bool { false }

}
#endif
