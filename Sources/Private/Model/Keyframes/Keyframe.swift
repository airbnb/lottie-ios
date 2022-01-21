//
//  Keyframe.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import CoreGraphics
import Foundation

// MARK: - Keyframe

/**
 Keyframe represents a point in time and is the container for datatypes.
 Note: This is a parent class and should not be used directly.
 */
public final class Keyframe<T> {

  // MARK: Lifecycle

  /// Initialize a value-only keyframe with no time data.
  public init(
    _ value: T,
    spatialInTangent: Vector3D? = nil,
    spatialOutTangent: Vector3D? = nil)
  {
    self.value = value
    time = 0
    isHold = true
    inTangent = nil
    outTangent = nil
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }

  /// Initialize a keyframe
  public init(
    value: T,
    time: AnimationFrameTime,
    isHold: Bool = false,
    inTangent: Vector2D? = nil,
    outTangent: Vector2D? = nil,
    spatialInTangent: Vector3D? = nil,
    spatialOutTangent: Vector3D? = nil)
  {
    self.value = value
    self.time = time
    self.isHold = isHold
    self.outTangent = outTangent
    self.inTangent = inTangent
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }

  // MARK: Internal

  /// The value of the keyframe
  public let value: T
  /// The time in frames of the keyframe.
  public let time: AnimationFrameTime
  /// A hold keyframe freezes interpolation until the next keyframe that is not a hold.
  public let isHold: Bool
  /// The in tangent for the time interpolation curve.
  public let inTangent: Vector2D?
  /// The out tangent for the time interpolation curve.
  public let outTangent: Vector2D?

  /// The spatial in tangent of the vector.
  public let spatialInTangent: Vector3D?
  /// The spatial out tangent of the vector.
  public let spatialOutTangent: Vector3D?
}

extension Keyframe: Equatable where T: Equatable {
  public static func == (lhs: Keyframe<T>, rhs: Keyframe<T>) -> Bool {
    lhs.value == rhs.value
      && lhs.time == rhs.time
      && lhs.isHold == rhs.isHold
      && lhs.inTangent == rhs.inTangent
      && lhs.outTangent == rhs.outTangent
      && lhs.spatialInTangent == rhs.spatialOutTangent
      && lhs.spatialOutTangent == rhs.spatialOutTangent
  }
}

extension Keyframe: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
    hasher.combine(time)
    hasher.combine(isHold)
    hasher.combine(inTangent)
    hasher.combine(outTangent)
    hasher.combine(spatialInTangent)
    hasher.combine(spatialOutTangent)
  }
}

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

extension KeyframeData: Encodable where T: Encodable { }
extension KeyframeData: Decodable where T: Decodable { }
