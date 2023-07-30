// Created by Cal Stephens on 6/28/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

struct ContentView: View {
  var body: some View {
    HStack {
      VStack {
        LottieView(animation: .named("Samples/LottieLogo1"))
          .looping()
          .frame(maxWidth: 100)

        Text("maxWidth: 100")
      }

      VStack {
        LottieView(animation: .named("Samples/LottieLogo1"))
          .looping()
          .frame(maxHeight: 100)

        Text("maxHeight: 100")
      }

      VStack {
        LottieView(animation: .named("Samples/LottieLogo1"))
          .resizable()
          .looping()

        Text("resizable")
      }

      VStack {
        LottieView(animation: .named("Samples/LottieLogo1"))
          .looping()

        Text("intrinsic content size")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
