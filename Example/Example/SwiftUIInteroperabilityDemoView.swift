// Created by miguel_jimenez on 1/19/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - SwiftUIInteroperabilityDemoView

struct SwiftUIInteroperabilityDemoView: View {

  var body: some View {
    List {
      Demo(name: "On appear offset animation") {
        OnAppearOffsetAnimation()
      }

      Demo(name: "Placeholder size inheritance") {
        PlaceholderSizeInheritance()
      }
    }
    .navigationTitle("SwiftUI Interoperability Demo")
  }
}

struct Demo<Content: View>: View {

  init(name: String, @ViewBuilder content:  () -> Content) {
    self.name = name
    self.content = content()
  }

  let name: String
  let content: Content
  @State private var show: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      Text(name)
        .frame(alignment: .top)
      Spacer()
      HStack(alignment: .center) {
        Button(show ? "Hide" : "Show") {
          show.toggle()
        }
        if show {
          content
        }
      }
      Spacer()
    }
    .frame(height: 150)
  }
}

/// Demonstrates how `LottieView` is animated by the `.offset` modifier.
struct OnAppearOffsetAnimation: View {

  @State private var demo1Appeared = false

  var body: some View {
    LottieView {
      try await DotLottieFile.named("Samples/DotLottie/multiple_animations.lottie")
    } placeholder: {
      LoadingIndicator()
    }
    .looping()
    .resizable()
    .frame(width: 100, height: 100)
    .offset(x: demo1Appeared ? 0 : 300)
    .onAppear {
      withAnimation {
        demo1Appeared = true
      }
    }
  }
}

/// Demonstrates how the placeholder's `Rectangle` get's its size from it's parent.
struct PlaceholderSizeInheritance: View {

  var body: some View {
    HStack(alignment: .top) {
      LottieView {
        await LottieAnimation.loadedFrom(url: URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!)
      } placeholder: {
        Rectangle()
          .fill(.red)
          .cornerRadius(20)
      }
      .resizable()
      .frame(width: 100, height: 100)

      LottieView {
        await LottieAnimation.loadedFrom(url: URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!)
      } placeholder: {
        Rectangle()
          .fill(.red)
          .cornerRadius(10)
      }
      .resizable()
      .frame(width: 50, height: 50)

      LottieView {
        await LottieAnimation.loadedFrom(url: URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!)
      } placeholder: {
        Rectangle()
          .fill(.red)
          .cornerRadius(3)
      }
      .resizable()
      .frame(width: 10, height: 10)
    }

  }
}