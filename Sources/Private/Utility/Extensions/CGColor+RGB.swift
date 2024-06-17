// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CGColor {
  /// Retrieves the red, green, and blue color values from this `CGColor`
  var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
    guard let components else { return nil }

    switch numberOfComponents {
    case 2:
      return (red: components[0], green: components[0], blue: components[0])

    case 3, 4:
      return (red: components[0], green: components[1], blue: components[2])

    default:
      // Unsupported conversion
      return nil
    }
  }

  /// Initializes a `CGColor` using the given `RGB` values
  static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> CGColor {
    rgba(red, green, blue, 1.0)
  }

  /// Initializes a `CGColor` using the given grayscale value
  static func gray(_ gray: CGFloat) -> CGColor {
    CGColor(
      colorSpace: CGColorSpaceCreateDeviceGray(),
      components: [gray, 1.0])!
  }

  /// Initializes a `CGColor` using the given `RGBA` values
  static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> CGColor {
    CGColor(
      colorSpace: LottieConfiguration.shared.colorSpace,
      components: [red, green, blue, alpha])!
  }

}
