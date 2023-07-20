// Created by Cal Stephens on 6/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationPreviewView

/// TODO: Implement functionality from UIKit `AnimationPreviewViewController`
struct AnimationPreviewView: View {

  // MARK: Internal

  let animationName: String

  var body: some View {
    VStack {
      LottieView(animation: .named(animationName))
        .imageProvider(.exampleAppSampleImages)
        .resizable()
        .looping()
        .currentProgress(animationPlaying ? nil : sliderValue)
        .getRealtimeAnimationProgress(animationPlaying ? $sliderValue : nil)

      Spacer()

      #if !os(tvOS)
      Slider(value: $sliderValue, in: 0...1, onEditingChanged: { editing in
        if animationPlaying, editing {
          animationPlaying = false
        }
      })
      .padding(.all, 16)
      #endif
    }
    .navigationTitle(animationName.components(separatedBy: "/").last!)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondaryBackground)
  }

  // MARK: Private

  @State private var animationPlaying = true
  @State private var sliderValue: AnimationProgressTime = 0

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

extension AnimationImageProvider where Self == FilepathImageProvider {
  static var exampleAppSampleImages: FilepathImageProvider {
    FilepathImageProvider(filepath: Bundle.main.resourceURL!.appending(path: "Samples/Images"))
  }
}
