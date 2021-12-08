//
//  ColorValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation

/// A `ValueProvider` that returns a CGColor Value
public final class ColorValueProvider: AnyValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping ColorValueBlock) {
    self.block = block
    color = Color(r: 0, g: 0, b: 0, a: 1)
  }

  /// Initializes with a single color.
  public init(_ color: Color) {
    self.color = color
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

  public func hasUpdate(frame _: CGFloat) -> Bool {
    if block != nil {
      return true
    }
    return hasUpdate
  }

  public func value(frame: CGFloat) -> Any {
    hasUpdate = false
    let newColor: Color
    if let block = block {
      newColor = block(frame)
    } else {
      newColor = color
    }
    return newColor
  }

  // MARK: Private

  private var hasUpdate: Bool = true

  private var block: ColorValueBlock?
}
