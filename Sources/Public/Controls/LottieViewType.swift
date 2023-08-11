// Created by Cal Stephens on 8/11/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

#if canImport(UIKit)
import UIKit

/// The control base type for this platform.
///  - `UIControl` on iOS / tvOS and `NSControl` on macOS.
public typealias LottieControlType = UIControl

/// The `State` type of `LottieControlType`
///  - `UIControl.State` on iOS / tvOS and `NSControl.StateValue` on macOS.
public typealias LottieControlState = UIControl.State
#else
import AppKit

/// The control base type for this platform.
///  - `UIControl` on iOS / tvOS and `NSControl` on macOS.
public typealias LottieControlType = NSControl

/// The `State` type of `LottieControlType`
///  - `UIControl.State` on iOS / tvOS and `NSControl.StateValue` on macOS.
public typealias LottieControlState = LottieNSLottieControlState

/// AppKit equivalent of `UIControl.State` for `AnimatedControl`
public enum LottieNSLottieControlState: UInt, RawRepresentable {
  /// The normal, or default, state of a control where the control is enabled but neither selected nor highlighted.
  case normal
  /// The highlighted state of a control.
  case highlighted
}
#endif
