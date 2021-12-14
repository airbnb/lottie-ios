// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// Configuration for experimental features that are in development
///
/// Experimental features are not considered stable and are subject
/// to change or be removed at any time.
public struct ExperimentalFeatureConfiguration {

  /// The singleton configuration for experimental features,
  /// which applies to all `AnimationView`s by default.
  public static var shared = ExperimentalFeatureConfiguration()

  /// Whether or not to use the new, experimental, rendering engine
  public var useNewRenderingEngine = false

}
