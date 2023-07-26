// Created by miguel_jimenez on 7/25/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationListView

struct RemoteAnimationsDemoView: View {

  struct Item: Hashable {
    let name: String
    let url: URL
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(items, id: \.self) { item in
          NavigationLink(value: item.url) {
            HStack {
              LottieView {
                await LottieAnimation.loadedFrom(url: item.url)
              }
              .currentProgress(0.5)
              .imageProvider(.exampleAppSampleImages)
              .frame(width: 50, height: 50)
              .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

              Text(item.name)
            }
          }
          .navigationDestination(for: URL.self) { url in
            AnimationPreviewView(animationSource: .remote(url: url))
          }
        }
      }.navigationTitle("Remote Animations")
    }
  }

  var items: [Item] {
    [
      Item(
        name: "Rooms Animation",
        url: URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!),
    ]
  }

}
