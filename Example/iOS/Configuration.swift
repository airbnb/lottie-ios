// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import Lottie

// MARK: - Configuration

final class Configuration {

  /// The rendering engine to use
  static var renderingEngineOption: RenderingEngineOption {
    get {
      RenderingEngineOption(rawValue: UserDefaults.standard.string(forKey: #function) ?? "Automatic") ?? .automatic
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: #function)
      applyCurrentConfiguration()
    }
  }

  /// The rendering engine to use
  static var previewImplementation: AnimationPreviewImplementation {
    get {
      AnimationPreviewImplementation(rawValue: UserDefaults.standard.string(forKey: #function) ?? "SwiftUI") ?? .swiftUI
    }
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: #function)
    }
  }

  /// Applies the current configuration (stored in UserDefaults)
  /// to the singleton `LottieConfiguration.shared`
  static func applyCurrentConfiguration() {
    LottieConfiguration.shared.renderingEngine = renderingEngineOption
  }

}

// MARK: - AnimationPreviewImplementation

enum AnimationPreviewImplementation: String, RawRepresentable {
  /// Preview animations using the UIKit `AnimationPreviewViewController`
  case uiKit = "UIKit"
  /// Preview animations using the SwiftUI `AnimationPreviewView`
  case swiftUI = "SwiftUI"
}
