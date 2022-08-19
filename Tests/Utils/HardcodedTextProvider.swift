// Created by Igor Katselenbogen on 08/19/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import QuartzCore
#if os(iOS)
import UIKit
#endif

// MARK: - HardcodedImageProvider

/// An `AnimationTextProvider` that always returns a specific hardcoded text
class HardcodedTextProvider: AnimationTextProvider {
  private let text: String

  init(text: String) {
    self.text = text
  }

  func textFor(keypathName: String, sourceText: String) -> String {
    text
  }
}
