// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import Lottie

final class Configuration {

  /// Whether or not to use the new, experimental rendering engine
  static var useNewRenderingEngine: Bool {
    get { UserDefaults.standard.bool(forKey: #function) }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      applyCurrentConfiguration()
    }
  }

  /// Applies the current configuration (stored in UserDefaults)
  /// to the singleton `LottieConfiguration.shared`
  static func applyCurrentConfiguration() {
    if useNewRenderingEngine {
      LottieConfiguration.shared.renderingEngine = .coreAnimation
    } else {
      LottieConfiguration.shared.renderingEngine = .mainThread
    }
  }

}
