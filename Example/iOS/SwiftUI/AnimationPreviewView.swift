// Created by Cal Stephens on 6/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

/// TODO: Implement functionality from UIKit `AnimationPreviewViewController`
struct AnimationPreviewView: View {

  let animationName: String

  var body: some View {
    VStack {
      // TODO: Should `LottieView` take an optional `LottieAnimation` so it can support
      // this sort of spelling without a forced-unwrap?
      LottieView(animation: LottieAnimation.named(animationName)!)
        .resizable()
        .looping()
    }
    .navigationTitle(animationName.components(separatedBy: "/").last!)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(uiColor: .secondarySystemBackground))
  }

}
