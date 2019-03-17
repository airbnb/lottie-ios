//
//  KeyframeGroupInterpolator.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import CoreGraphics

/// A value provider that produces an array of values from an array of Keyframe Interpolators
class GroupInterpolator<ValueType>: AnyValueProvider where ValueType: Interpolatable {
  var valueType: Any.Type {
    return [ValueType].self
  }
  
  func hasUpdate(frame: CGFloat) -> Bool {
    for interpolator in keyframeInterpolators {
      if interpolator.hasUpdate(frame: frame) {
        return true
      }
    }
    return false
  }
  
  func value(frame: CGFloat) -> Any {
    var output = [ValueType]()
    for interpolator in keyframeInterpolators {
      output.append(interpolator.value(frame: frame) as! ValueType)
    }
    return output
  }
  
  /// Initialize with an array of array of keyframes.
  init(keyframeGroups: [[Keyframe<ValueType>]]) {
    var interpolators = [KeyframeInterpolator<ValueType>]()
    for keyframes in keyframeGroups {
      interpolators.append(KeyframeInterpolator(keyframes: keyframes))
    }
    self.keyframeInterpolators = interpolators
  }
  let keyframeInterpolators: [KeyframeInterpolator<ValueType>]
  
}
