//
//  Keyframe.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import CoreGraphics
import Foundation

// MARK: - KeyframeData

/**
 A generic class used to parse and remap keyframe json.

 Keyframe json has a couple of different variations and formats depending on the
 type of keyframea and also the version of the JSON. By parsing the raw data
 we can reconfigure it into a constant format.
 */
final class KeyframeData<T> {

  // MARK: Lifecycle

  init(
    startValue: T?,
    endValue: T?,
    time: Double?,
    hold: Int?,
    inTangent: Vector2D?,
    outTangent: Vector2D?,
    spatialInTangent: Vector3D?,
    spatialOutTangent: Vector3D?)
  {
    self.startValue = startValue
    self.endValue = endValue
    self.time = time
    self.hold = hold
    self.inTangent = inTangent
    self.outTangent = outTangent
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case startValue = "s"
    case endValue = "e"
    case time = "t"
    case hold = "h"
    case inTangent = "i"
    case outTangent = "o"
    case spatialInTangent = "ti"
    case spatialOutTangent = "to"
  }

  /// The start value of the keyframe
  let startValue: T?
  /// The End value of the keyframe. Note: Newer versions animation json do not have this field.
  let endValue: T?
  /// The time in frames of the keyframe.
  let time: Double?
  /// A hold keyframe freezes interpolation until the next keyframe that is not a hold.
  let hold: Int?

  /// The in tangent for the time interpolation curve.
  let inTangent: Vector2D?
  /// The out tangent for the time interpolation curve.
  let outTangent: Vector2D?

  /// The spacial in tangent of the vector.
  let spatialInTangent: Vector3D?
  /// The spacial out tangent of the vector.
  let spatialOutTangent: Vector3D?

  var isHold: Bool {
    if let hold = hold {
      return hold > 0
    }
    return false
  }
}

// MARK: Encodable

extension KeyframeData: Encodable where T: Encodable { }

// MARK: Decodable

extension KeyframeData: Decodable where T: Decodable { }
