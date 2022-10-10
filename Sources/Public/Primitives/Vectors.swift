//
//  Vectors.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation

// MARK: - Vector1D

@available(*, deprecated, renamed: "LottieVector1D", message: """
  `Lottie.Vector1D` has been renamed to `LottieVector1D` for consistency with \
  the new `LottieVector3D` type. This notice will be removed in Lottie 4.0.
  """)
public typealias Vector1D = LottieVector1D

// MARK: - LottieVector1D

public struct LottieVector1D: Hashable {

  public init(_ value: Double) {
    self.value = value
  }

  public let value: Double

}

// MARK: - Vector3D

@available(*, deprecated, renamed: "LottieVector3D", message: """
  `Lottie.Vector3D` has been renamed to `LottieVector3D`, to prevent conflicts with \
  the Apple SDK `Spatial.Vector3D` type. This notice will be removed in Lottie 4.0.
  """)
public typealias Vector3D = LottieVector3D

// MARK: - LottieVector3D

/// A three dimensional vector.
/// These vectors are encoded and decoded from [Double]
public struct LottieVector3D: Hashable {

  public let x: Double
  public let y: Double
  public let z: Double

  public init(x: Double, y: Double, z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }

}
