//
//  StringExtensions.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import CoreGraphics
import Foundation

extension String {

  var cgColor: CGColor {
    let (red, green, blue) = hexColorComponents()
    return .rgb(red, green, blue)
  }

  var lottieColor: LottieColor {
    let (red, green, blue) = hexColorComponents()
    return .init(r: red, g: green, b: blue, a: 1.0)
  }

  func hexColorComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    var cString: String = trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }

    if (cString.count) != 6 {
      return (red: 0, green: 0, blue: 0)
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return (
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0)
  }

  /// Checks if the string consists only of whitespace characters.
  ///
  /// - Returns: `true` if the string contains only whitespace characters, including newlines, or is empty; otherwise, `false`.
  ///
  /// Example:
  ///
  /// ```swift
  /// let blankString = "   "
  /// let nonBlankString = "Hello, World!"
  ///
  /// let isBlank = blankString.isBlank // isBlank will be true
  /// let isNonBlank = nonBlankString.isBlank // isNonBlank will be false
  /// ```
  @inlinable var isBlank: Bool { allSatisfy { $0.isWhitespace } }
}
