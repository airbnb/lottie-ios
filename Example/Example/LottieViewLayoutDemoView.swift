// Created by Cal Stephens on 6/28/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

struct LottieViewLayoutDemoView: View {
  var body: some View {
    HStack {
      VStack {
        LottieView(animation: .named("Samples/LottieLogo1"))
          .configure(\.contentMode, to: .scaleAspectFit)
          .looping()
          .frame(maxWidth: 100)

        Text("maxWidth: 100, contentMode: .scaleAspectFit")
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

        Text("automatic size")
      }

      VStack {
        LottieView {
          try await Task.sleep(for: .seconds(1))
          return LottieAnimation.named("Samples/LottieLogo1")
        }
        .intrinsicSize()
        .looping()

        Text("intrinsic size, async")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
