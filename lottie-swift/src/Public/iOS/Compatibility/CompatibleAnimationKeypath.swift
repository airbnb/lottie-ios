//
//  CompatibleAnimationKeypath.swift
//  Lottie_iOS
//
//  Created by Tyler Hedrick on 3/6/19.
//

import Foundation

@objc
/// An Objective-C compatible wrapper around Lottie's AnimationKeypath
public final class CompatibleAnimationKeypath: NSObject {

  @objc
  /// Creates a keypath from a dot separated string. The string is separated by "."
  public init(keypath: String) {
    animationKeypath = AnimationKeypath(keypath: keypath)
  }

  @objc
  /// Creates a keypath from a list of strings.
  public init(keys: [String]) {
    animationKeypath = AnimationKeypath(keys: keys)
  }

  public let animationKeypath: AnimationKeypath
}
