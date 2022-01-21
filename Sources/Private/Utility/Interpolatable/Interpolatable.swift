//
//  Interpolatable.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/14/19.
//

import CoreGraphics
import Foundation

public protocol Interpolatable {

  func interpolateTo(
    _ to: Self,
    amount: CGFloat,
    spatialOutTangent: CGPoint?,
    spatialInTangent: CGPoint?) -> Self

}
