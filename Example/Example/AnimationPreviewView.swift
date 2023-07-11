// Created by Cal Stephens on 6/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationPreviewView

/// TODO: Implement functionality from UIKit `AnimationPreviewViewController`
struct AnimationPreviewView: View {

  let animationName: String

  var body: some View {
    VStack {
      LottieView(animation: .named(animationName))
        .resizable()
        .looping()
    }
    .navigationTitle(animationName.components(separatedBy: "/").last!)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondaryBackground)
  }

}

extension Color {
  static var secondaryBackground: Color {
    #if os(iOS)
    Color(uiColor: .secondarySystemBackground)
    #else
      .clear
    #endif
  }
}
