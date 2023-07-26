// Created by Cal Stephens on 6/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationPreviewView

/// TODO: Implement functionality from UIKit `AnimationPreviewViewController`
struct AnimationPreviewView: View {

  // MARK: Internal

  enum AnimationSource {
    case local(animationPath: String)
    case remote(url: URL)

    var name: String {
      switch self {
      case .local(let name):
        return name
      case .remote:
        return "Remote animation"
      }
    }
  }

  let animationSource: AnimationSource

  var body: some View {
    VStack {
      lottieView
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
    .navigationTitle(animationSource.name.components(separatedBy: "/").last!)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondaryBackground)
  }

  // MARK: Private

  @State private var animationPlaying = true
  @State private var sliderValue: AnimationProgressTime = 0

  @ViewBuilder
  private var lottieView: some View {
    switch animationSource {
    case .local(let name):
      localAnimation(animationName: name)
    case .remote(let url):
      LottieView {
        await LottieAnimation.loadedFrom(url: url)
      } placeholder: {
        LoadingIndicator()
      }
      .imageProvider(.exampleAppSampleImages)
      .resizable()
      .looping()
      .currentProgress(animationPlaying ? nil : sliderValue)
      .getRealtimeAnimationProgress(animationPlaying ? $sliderValue : nil)
    }
  }

  @ViewBuilder
  private func localAnimation(animationName: String) -> some View {
    if let animation = LottieAnimation.named(animationName) {
      LottieView(animation: animation)
        .imageProvider(.exampleAppSampleImages)
        .resizable()
        .looping()
        .currentProgress(animationPlaying ? nil : sliderValue)
        .getRealtimeAnimationProgress(animationPlaying ? $sliderValue : nil)
    } else {
      LottieView {
        try await DotLottieFile.named(animationName)
      } placeholder: {
        LoadingIndicator()
      }
      .imageProvider(.exampleAppSampleImages)
      .resizable()
      .looping()
      .currentProgress(animationPlaying ? nil : sliderValue)
      .getRealtimeAnimationProgress(animationPlaying ? $sliderValue : nil)
    }
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

extension AnimationImageProvider where Self == FilepathImageProvider {
  static var exampleAppSampleImages: FilepathImageProvider {
    FilepathImageProvider(filepath: Bundle.main.resourceURL!.appending(path: "Samples/Images"))
  }
}

// MARK: - LoadingIndicator

struct LoadingIndicator: View {
  @State private var animating = false

  var body: some View {
    Image(systemName: "rays")
      .rotationEffect(animating ? Angle.degrees(360) : .zero)
      .animation(
        Animation
          .linear(duration: 2)
          .repeatForever(autoreverses: false),
        value: animating)
      .onAppear {
        animating = true
      }
  }
}
