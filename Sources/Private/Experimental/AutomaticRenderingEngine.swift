// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import CoreGraphics
import Foundation

extension Animation {
  /// Whether or not this animation can be rendered by the Core Animation engine
  ///  - This is a somewhat expensive check, because it constructs an `AnimationView`
  ///    that renders the animation and validates that it is set up properly.
  var supportedByCoreAnimationEngine: Bool {
    var supportedByCoreAnimationEngine = true

    let animationLayer = ExperimentalAnimationLayer(
      animation: self,
      imageProvider: BundleImageProvider(bundle: Bundle.main, searchPath: nil),
      fontProvider: DefaultFontProvider(),
      compatibilityTrackerMode: .abort,
      didSetUpAnimation: { error in
        if error != nil {
          supportedByCoreAnimationEngine = false
        }
      })

    if !supportedByCoreAnimationEngine {
      return false
    }

    animationLayer.bounds = CGRect(origin: .zero, size: size)
    animationLayer.layoutIfNeeded()
    animationLayer.display()

    return supportedByCoreAnimationEngine
  }
}
