// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - ExperimentalAnimationLayer

/// The root `CALayer` of the experimental rendering engine,
/// which leverages the Core Animation render server to
/// animate without executing on the main thread every frame.
final class ExperimentalAnimationLayer: CALayer {

  // MARK: Lifecycle

  init(animation: Animation) {
    self.animation = animation
    super.init()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private let animation: Animation

}

// MARK: RootAnimationLayer

extension ExperimentalAnimationLayer: RootAnimationLayer {

  var currentFrame: CGFloat {
    get { 0 }
    set { /* Currently unsupported */ }
  }

  var renderScale: CGFloat {
    get { 0 }
    set { fatalError("Currently unsupported") }
  }

  var respectAnimationFrameRate: Bool {
    get { false }
    set { fatalError("Currently unsupported") }
  }

  var animationLayers: ContiguousArray<CompositionLayer> {
    []
  }

  var imageProvider: AnimationImageProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  var textProvider: AnimationTextProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  var fontProvider: AnimationFontProvider {
    get { fatalError("Currently unsupported") }
    set { fatalError("Currently unsupported") }
  }

  func reloadImages() {
    fatalError("Currently unsupported")
  }

  func forceDisplayUpdate() {
    // Unimplemented
  }

  func logHierarchyKeypaths() {
    fatalError("Currently unsupported")
  }

  func setValueProvider(_: AnyValueProvider, keypath _: AnimationKeypath) {
    fatalError("Currently unsupported")
  }

  func getValue(for _: AnimationKeypath, atFrame _: AnimationFrameTime?) -> Any? {
    fatalError("Currently unsupported")
  }

  func layer(for _: AnimationKeypath) -> CALayer? {
    fatalError("Currently unsupported")
  }

  func animatorNodes(for _: AnimationKeypath) -> [AnimatorNode]? {
    fatalError("Currently unsupported")
  }

}
