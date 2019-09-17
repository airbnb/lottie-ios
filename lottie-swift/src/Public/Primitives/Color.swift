//
//  Color.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation

public enum ColorFormatDenominator {
  case One
  case OneHundred
  case TwoFiftyFive
  
  var value: Double {
    switch self {
    case .One:
      return 1.0
    case .OneHundred:
      return 100.0
    case .TwoFiftyFive:
      return 255.0
    }
  }
}

public struct Color {
  
  var r: Double
  var g: Double
  var b: Double
  var a: Double
  
  public init(r: Double, g: Double, b: Double, a: Double, denominator: ColorFormatDenominator = .One) {
    self.r = r / denominator.value
    self.g = g / denominator.value
    self.b = b / denominator.value
    self.a = a / denominator.value
  }
  
}
