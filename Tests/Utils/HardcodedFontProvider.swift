// Created by Cal Stephens on 2/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import QuartzCore
#if os(iOS)
import UIKit
#endif

// MARK: - HardcodedFontProvider

/// An `AnimationFontProvider` that always returns a specific hardcoded font
struct HardcodedFontProvider: AnimationFontProvider {
  let font: CTFont

  func fontFor(family _: String, size _: CGFloat) -> CTFont? {
    font
  }
}
