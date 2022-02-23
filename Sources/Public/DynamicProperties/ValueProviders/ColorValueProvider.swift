//
//  ColorValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation

/// A `ValueProvider` that returns a CGColor Value
public final class ColorValueProvider: ValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping ColorValueBlock) {
    self.block = block
    color = Color(r: 0, g: 0, b: 0, a: 1)
    keyframes = nil
  }

  /// Initializes with a single color.
  public init(_ color: Color) {
    self.color = color
    block = nil
    keyframes = nil
    hasUpdate = true
  }

  /// Initializes with multiple colors, with timing information
  public init(_ keyframes: [Keyframe<Color>]) {
    self.keyframes = keyframes
    color = Color(r: 0, g: 0, b: 0, a: 1)
    block = nil
    hasUpdate = true
  }

  // MARK: Public

  /// Returns a Color for a CGColor(Frame Time)
  public typealias ColorValueBlock = (CGFloat) -> Color

  /// The color value of the provider.
  public var color: Color {
    didSet {
      hasUpdate = true
    }
  }

  // MARK: ValueProvider Protocol

  public var valueType: Any.Type {
    Color.self
  }

  public var storage: ValueProviderStorage<Color> {
    if let block = block {
      return .closure { frame in
        self.hasUpdate = false
        return block(frame)
      }
    } else if let keyframes = keyframes {
      return .keyframes(keyframes)
    } else {
      hasUpdate = false
      return .singleValue(color)
    }
  }

  public func hasUpdate(frame _: CGFloat) -> Bool {
    if block != nil {
      return true
    }
    return hasUpdate
  }

  // MARK: Private

  private var hasUpdate = true

  private var block: ColorValueBlock?
  private var keyframes: [Keyframe<Color>]?
}
