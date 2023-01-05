// Created by Cal Stephens on 1/4/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import Lottie
import UIKit

// MARK: - ControlsDemoViewController

final class ControlsDemoViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    let layout = UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))

    super.init(layout: layout)
    setItems(items, animated: false)

    title = "Controls Demo"
  }

  // MARK: Private

  @ItemModelBuilder
  private var items: [ItemModeling] {
    AnimatedSwitchRow.itemModel(
      dataID: "Switch",
      content: .init(
        animationName: "Samples/Switch",
        title: "Switch",
        onTimeRange: 0.5...1.0,
        offTimeRange: 0.0...0.5))

    AnimatedSwitchRow.itemModel(
      dataID: "Switch (Custom Colors)",
      content: .init(
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
        ]))

    AnimatedButtonRow.itemModel(
      dataID: "Button",
      content: .init(
        animationName: "Samples/TwitterHeartButton",
        title: "Twitter Heart Button",
        playRanges: [
          .init(fromMarker: "touchDownStart", toMarker: "touchDownEnd", event: .touchDown),
          .init(fromMarker: "touchDownEnd", toMarker: "touchUpCancel", event: .touchUpOutside),
          .init(fromMarker: "touchDownEnd", toMarker: "touchUpEnd", event: .touchUpInside),
        ]))

    AnimatedSwitchRow.itemModel(
      dataID: "issue-1877",
      content: .init(
        animationName: "Samples/Issues/issue_1877",
        title: "Issue #1877",
        onTimeRange: nil, // use the default (0...1)
        offTimeRange: nil, // use the default (1...0)
        colorValueProviders: ["**.Color": [Keyframe(.black)]]))
  }

}

extension LottieColor {
  static var black: LottieColor {
    .init(r: 0, g: 0, b: 0, a: 1)
  }
}
