// Created by Cal Stephens on 6/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SwiftUI
import Lottie

struct AnimationPreviewView: View {
  var body: some View {
    LottieView(animation: LottieAnimation.named("Samples/LottieLogo1")!)
      .resizable()
      .looping()
  }
}
