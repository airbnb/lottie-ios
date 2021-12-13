// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

public struct ExperimentalFeatureConfiguration {

  /// The singleton configuration for experimental features,
  /// which applies to all `AnimationView`s.
  public static var shared = ExperimentalFeatureConfiguration()

  /// Whether or not to use the new, experimental, rendering engine
  public var useNewRenderingEngine = false

}
