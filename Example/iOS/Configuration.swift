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

  /// Applies the current configuration (stored in UserDefaults)
  /// to the singleton `LottieConfiguration.shared`
  static func applyCurrentConfiguration() {
    LottieConfiguration.shared.renderingEngine = renderingEngineOption
  }

}
