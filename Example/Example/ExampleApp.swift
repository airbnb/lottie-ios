// Created by Cal Stephens on 7/5/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SwiftUI

@main
struct ExampleApp: App {

  // MARK: Lifecycle

  init() {
    // Register fonts from the Samples/Fonts directory
    for fontAssetURL in Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: "Samples/Fonts") ?? [] {
      CTFontManagerRegisterFontsForURL(fontAssetURL as CFURL, .process, nil)
    }
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        AnimationListView(content: .directory("Samples"))
      }
    }
  }

}
