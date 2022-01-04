// Created by Cal Stephens on 1/4/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import Lottie
import UIKit

final class ControlsDemoViewController: CollectionViewController {

  // MARK: Lifecycle

  init() {
    let layout = UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))

    super.init(layout: layout)
    setItems(items, animated: false)

    title = "Controls Demo"
  }

  // MARK: Internal

  var items: [ItemModeling] {
    [
      AnimatedSwitchRow.itemModel(
        dataID: "Switch",
        content: .init(
          animationName: "Samples/Switch",
          title: "Switch",
          onTimeRange: (from: 0.5, to: 1.0),
          offTimeRange: (from: 0.0, to: 0.5))),

      AnimatedButtonRow.itemModel(
        dataID: "Button",
        content: .init(
          animationName: "Samples/TwitterHeartButton",
          title: "Twitter Heart Button",
          playRanges: [
            (fromMarker: "touchDownStart", toMarker: "touchDownEnd", event: .touchDown),
            (fromMarker: "touchDownEnd", toMarker: "touchUpCancel", event: .touchUpOutside),
            (fromMarker: "touchDownEnd", toMarker: "touchUpEnd", event: .touchUpInside),
          ])),
    ]
  }

}
