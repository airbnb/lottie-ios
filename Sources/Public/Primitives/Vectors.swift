//
//  Vectors.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation

// MARK: - Vector1D

public struct Vector1D: Hashable {

  public init(_ value: Double) {
    self.value = value
  }

  public let value: Double

}

// MARK: - Vector3D

/// A three dimensional vector.
/// These vectors are encoded and decoded from [Double]
public struct Vector3D: Hashable {

  public let x: Double
  public let y: Double
  public let z: Double

  public init(x: Double, y: Double, z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }

}
