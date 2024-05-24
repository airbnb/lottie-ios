// Created by Cal Stephens on 1/20/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Spacer()
      Text("CarthageTest")
      Spacer()

      LottieView(animation: .named("LottieLogo1"))
        .playing(loopMode: .loop)
    }
  }
}
