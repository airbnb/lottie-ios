// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Foundation
import Lottie

// MARK: - Configuration

final class Configuration {

  /// Whether or not to use the new, experimental rendering engine
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

// MARK: - RenderingEngineOption + RawRepresentable

extension RenderingEngineOption: RawRepresentable {

  // MARK: Lifecycle

  public init?(rawValue: String) {
    switch rawValue {
    case "Automatic":
      self = .automatic
    case "Main Thread":
      self = .mainThread
    case "Core Animation":
      self = .coreAnimation
    default:
      return nil
    }
  }

  // MARK: Public

  public var rawValue: String {
    switch self {
    case .automatic:
      return "Automatic"
    case .specific(.mainThread):
      return "Main Thread"
    case .specific(.coreAnimation):
      return "Core Animation"
    }
  }

}
