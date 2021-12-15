// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

/// A type that can construct a CALayer to display in a Lottie animation
protocol LayerConstructing {
  func makeLayer() -> CALayer
}
