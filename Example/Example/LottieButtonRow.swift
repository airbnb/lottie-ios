// Created by Cal Stephens on 8/14/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - LottieSwitchRow

struct LottieButtonRow: View {

  // MARK: Internal

  var animationName: String
  var title: String

  var body: some View {
    HStack {
      LottieButton(animation: .named(animationName)) {
        pressCount += 1
      }
      .animate(fromMarker: "touchDownStart", toMarker: "touchDownEnd", on: .touchDown)
      .animate(fromMarker: "touchDownEnd", toMarker: "touchUpCancel", on: .touchUpOutside)
      .animate(fromMarker: "touchDownEnd", toMarker: "touchUpEnd", on: .touchUpInside)
      .frame(width: 80, height: 80)

      Text(verbatim: "\(title) (pressCount=\(pressCount))")
    }
  }

  // MARK: Private

  @State private var pressCount = 0
}
