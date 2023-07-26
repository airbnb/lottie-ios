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

  let wrapInNavStack: Bool

  var body: some View {
    if wrapInNavStack {
      NavigationStack {
        listBody
      }
    } else {
      listBody
    }
  }

  var listBody: some View {
    List {
      ForEach(items, id: \.self) { item in
        NavigationLink(value: item) {
          HStack {
            LottieView {
              await LottieAnimation.loadedFrom(url: item.url)
            } placeholder: {
              LoadingIndicator()
            }
            .currentProgress(0.5)
            .imageProvider(.exampleAppSampleImages)
            .frame(width: 50, height: 50)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Text(item.name)
          }
        }
        .navigationDestination(for: Item.self) { item in
          AnimationPreviewView(animationSource: .remote(url: item.url, name: item.name))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Remote Animations")
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
