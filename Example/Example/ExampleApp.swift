// Created by Cal Stephens on 7/5/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SwiftUI

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        AnimationListView(directory: "Samples")
      }
    }
  }
}
