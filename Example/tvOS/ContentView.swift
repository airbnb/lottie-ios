// Created by Cal Stephens on 6/28/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

struct ContentView: View {
  var body: some View {
    ZStack {
      LottieView(animation: LottieAnimation.named("Samples/LottieLogo1")!)
        .looping()
        .resizable()
    }
    .ignoresSafeArea()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
