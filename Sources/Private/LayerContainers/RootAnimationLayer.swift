// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

/// A root `CALayer` responsible for playing a Lottie animation
protocol RootAnimationLayer: CALayer {
  var currentFrame: AnimationFrameTime { get set }
  var renderScale: CGFloat { get set }
  var respectAnimationFrameRate: Bool { get set }

  var _animationLayers: [CALayer] { get }
  var imageProvider: AnimationImageProvider { get set }
  var textProvider: AnimationTextProvider { get set }
  var fontProvider: AnimationFontProvider { get set }

  func reloadImages()
  func forceDisplayUpdate()
  func logHierarchyKeypaths()

  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath)
  func getValue(for keypath: AnimationKeypath, atFrame: AnimationFrameTime?) -> Any?

  func layer(for keypath: AnimationKeypath) -> CALayer?
  func animatorNodes(for keypath: AnimationKeypath) -> [AnimatorNode]?
}
