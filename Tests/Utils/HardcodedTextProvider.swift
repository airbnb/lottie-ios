// Created by Igor Katselenbogen on 08/19/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie

// MARK: - HardcodedTextProvider

/// An `AnimationTextProvider` that always returns a specific hardcoded text
class HardcodedTextProvider: AnimationTextProvider {

  // MARK: Lifecycle

  init(text: String) {
    self.text = text
  }

  // MARK: Internal

  func textFor(keypathName _: String, sourceText _: String) -> String {
    text
  }

  // MARK: Private

  private let text: String

}
