// Created by Cal Stephens on 8/11/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - ControlsDemoView

struct ControlsDemoView: View {

  var body: some View {
    List {
      LottieSwitchRow(
        animationName: "Samples/Switch",
        title: "Switch",
        onTimeRange: 0.5...1.0,
        offTimeRange: 0.0...0.5)

      LottieSwitchRow(
        animationName: "Samples/Switch",
        title: "Switch (Custom Colors)",
        onTimeRange: 0.5...1.0,
        offTimeRange: 0.0...0.5,
        colorValueProviders: [
          "Checkmark Outlines.Group 1.Stroke 1.Color": [Keyframe(.black)],
          "Checkmark Outlines 2.Group 1.Stroke 1.Color": [Keyframe(.black)],
          "X Outlines.Group 1.Stroke 1.Color": [Keyframe(.black)],
          "Switch Outline Outlines.Fill 1.Color": [
            Keyframe(value: LottieColor.black, time: 0),
            Keyframe(value: LottieColor(r: 0.76, g: 0.76, b: 0.76, a: 1), time: 75),
            Keyframe(value: LottieColor.black, time: 150),
          ],
        ])

      LottieButtonRow(
        animationName: "Samples/TwitterHeartButton",
        title: "Twitter Heart Button")

      LottieButtonRow(
        animationName: "Samples/Switch",
        title: "Switch as Button")

      LottieSwitchRow(
        animationName: "Samples/Issues/issue_1877",
        title: "Issue #1877",
        onTimeRange: nil, // use the default (0...1)
        offTimeRange: nil, // use the default (1...0)
        colorValueProviders: ["**.Color": [Keyframe(.black)]])
    }
    .navigationTitle("Controls Demo")
  }

}

extension LottieColor {
  static var black: LottieColor {
    .init(r: 0, g: 0, b: 0, a: 1)
  }
}
