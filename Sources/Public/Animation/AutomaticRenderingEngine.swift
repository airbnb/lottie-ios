// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation

extension RenderingEngineOption {
  public func renderingEngine(for animation: Animation) -> RenderingEngine {
    switch self {
    case .specific(let engine):
      return engine
    case .automatic:
      return animation.supportedByCoreAnimationEngine ? .coreAnimation : .mainThread
    }
  }

  public func renderingEngine(for animation: Animation?) -> RenderingEngine? {
    switch self {
    case .specific(let engine):
      return engine
    case .automatic:
      guard let animation = animation else { return nil }
      return animation.supportedByCoreAnimationEngine ? .coreAnimation : .mainThread
    }
  }
}

extension Animation {
  /// Whether or not this animation can be rendered by the Core Animation engine
  public var supportedByCoreAnimationEngine: Bool {
    true // TODO: Implement checks
  }
}
