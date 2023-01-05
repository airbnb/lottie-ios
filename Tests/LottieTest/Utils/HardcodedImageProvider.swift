// Created by Cal Stephens on 1/19/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import QuartzCore
#if os(iOS)
import UIKit
#endif

// MARK: - HardcodedImageProvider

/// An `AnimationImageProvider` that always returns a specific hardcoded image of a dog (hi Marley)
struct HardcodedImageProvider: AnimationImageProvider {
  let imageName: String

  func imageForAsset(asset _: ImageAsset) -> CGImage? {
    #if os(iOS)
    return UIImage(named: imageName, in: .module, compatibleWith: nil)?.cgImage
    #else
    return nil
    #endif
  }
}
