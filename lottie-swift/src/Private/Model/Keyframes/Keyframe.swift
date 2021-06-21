//
//  Keyframe.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation
import CoreGraphics

/**
 Keyframe represents a point in time and is the container for datatypes.
 Note: This is a parent class and should not be used directly.
 */
final class Keyframe<T: Interpolatable> {
  
  /// The value of the keyframe
  let value: T
  /// The time in frames of the keyframe.
  let time: CGFloat
  /// A hold keyframe freezes interpolation until the next keyframe that is not a hold.
  let isHold: Bool
  /// The in tangent for the time interpolation curve.
  let inTangent: Vector2D?
  /// The out tangent for the time interpolation curve.
  let outTangent: Vector2D?
  
  /// The spacial in tangent of the vector.
  let spatialInTangent: Vector3D?
  /// The spacial out tangent of the vector.
  let spatialOutTangent: Vector3D?
  
  /// Initialize a value-only keyframe with no time data.
  init(_ value: T,
       spatialInTangent: Vector3D? = nil,
       spatialOutTangent: Vector3D? = nil) {
    self.value = value
    self.time = 0
    self.isHold = true
    self.inTangent = nil
    self.outTangent = nil
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }
  
  /// Initialize a keyframe
  init(value: T,
       time: Double,
       isHold: Bool,
       inTangent: Vector2D?,
       outTangent: Vector2D?,
       spatialInTangent: Vector3D? = nil,
       spatialOutTangent: Vector3D? = nil) {
    self.value = value
    self.time = CGFloat(time)
    self.isHold = isHold
    self.outTangent = outTangent
    self.inTangent = inTangent
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }
  
}

/**
 A generic class used to parse and remap keyframe json.
 
 Keyframe json has a couple of different variations and formats depending on the
 type of keyframea and also the version of the JSON. By parsing the raw data
 we can reconfigure it into a constant format.
 */
final class KeyframeData<T>: Codable, DictionaryInitializable where T: Codable, T: AnyInitializable {
  
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
  let spatialOutTangent:Vector3D?
  
  init(startValue: T?,
       endValue: T?,
       time: Double?,
       hold: Int?,
       inTangent: Vector2D?,
       outTangent: Vector2D?,
       spatialInTangent: Vector3D?,
       spatialOutTangent: Vector3D?) {
    self.startValue = startValue
    self.endValue = endValue
    self.time = time
    self.hold = hold
    self.inTangent = inTangent
    self.outTangent = outTangent
    self.spatialInTangent = spatialInTangent
    self.spatialOutTangent = spatialOutTangent
  }
  
  init(dictionary: [String : Any]) throws {
    if let rawValue = dictionary[CodingKeys.startValue.rawValue] {
      self.startValue = try? T(value: rawValue)
    } else {
      self.startValue = nil
    }
    if let rawValue = dictionary[CodingKeys.endValue.rawValue] {
      self.endValue = try? T(value: rawValue)
    } else {
      self.endValue = nil
    }
    self.time = try? dictionary.valueFor(key: CodingKeys.time.rawValue)
    self.hold = try? dictionary.valueFor(key: CodingKeys.hold.rawValue)
    if let rawValue = dictionary[CodingKeys.inTangent.rawValue] {
      self.inTangent = try? Vector2D(value: rawValue)
    } else {
      self.inTangent = nil
    }
    if let rawValue = dictionary[CodingKeys.outTangent.rawValue] {
      self.outTangent = try? Vector2D(value: rawValue)
    } else {
      self.outTangent = nil
    }
    if let rawValue = dictionary[CodingKeys.spatialInTangent.rawValue] {
      self.spatialInTangent = try? Vector3D(value: rawValue)
    } else {
      self.spatialInTangent = nil
    }
    if let rawValue = dictionary[CodingKeys.spatialOutTangent.rawValue] {
      self.spatialOutTangent = try? Vector3D(value: rawValue)
    } else {
      self.spatialOutTangent = nil
    }
  }
  
  enum CodingKeys : String, CodingKey {
    case startValue = "s"
    case endValue = "e"
    case time = "t"
    case hold = "h"
    case inTangent = "i"
    case outTangent = "o"
    case spatialInTangent = "ti"
    case spatialOutTangent = "to"
  }
  
  var isHold: Bool {
    if let hold = hold {
      return hold > 0
    }
    return false
  }
}
