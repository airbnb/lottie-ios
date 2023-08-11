// Created by Cal Stephens on 8/11/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - LottieSwitchRow

struct LottieSwitchRow: View {

  // MARK: Internal

  var animationName: String
  var title: String
  var onTimeRange: ClosedRange<AnimationProgressTime>?
  var offTimeRange: ClosedRange<AnimationProgressTime>?
  var colorValueProviders: [String: [Keyframe<LottieColor>]] = [:]

  var body: some View {
    HStack {
      LottieSwitch(animation: .named(animationName))
        .isOn($isOn)
        .onAnimation(
          fromProgress: onTimeRange?.lowerBound ?? 0,
          toProgress: onTimeRange?.upperBound ?? 1)
        .offAnimation(
          fromProgress: offTimeRange?.lowerBound ?? 1,
          toProgress: offTimeRange?.upperBound ?? 0)
        .colorValueProviders(colorValueProviders)
        .frame(width: 80, height: 80)

      Text(verbatim: "\(title) (isOn=\(isOn))")
    }
  }

  // MARK: Private

  @State private var isOn = false
}

extension LottieSwitch {
  func colorValueProviders(_ colorValueProviders: [String: [Keyframe<LottieColor>]]) -> Self {
    var copy = self

    for (keypath, keyframes) in colorValueProviders {
      copy = copy.valueProvider(
        ColorValueProvider(keyframes),
        for: AnimationKeypath(keypath: keypath))
    }

    return copy
  }
}
