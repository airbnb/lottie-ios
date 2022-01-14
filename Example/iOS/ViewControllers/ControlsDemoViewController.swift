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
          "Switch Outline Outlines.Fill 1.Color": .black,
          "Checkmark Outlines.Group 1.Stroke 1.Color": .black,
          "Checkmark Outlines 2.Group 1.Stroke 1.Color": .black,
          "X Outlines.Group 1.Stroke 1.Color": .black,
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
  }

}

extension Color {
  static var black: Color {
    .init(r: 0, g: 0, b: 0, a: 1)
  }
}
