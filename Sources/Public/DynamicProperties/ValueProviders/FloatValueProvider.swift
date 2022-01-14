//
//  DoubleValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation

/// A `ValueProvider` that returns a CGFloat Value
public final class FloatValueProvider: ValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping CGFloatValueBlock) {
    self.block = block
    float = 0
  }

  /// Initializes with a single float.
  public init(_ float: CGFloat) {
    self.float = float
    block = nil
    hasUpdate = true
  }

  // MARK: Public

  /// Returns a CGFloat for a CGFloat(Frame Time)
  public typealias CGFloatValueBlock = (CGFloat) -> CGFloat

  public var float: CGFloat {
    didSet {
      hasUpdate = true
    }
  }

  // MARK: ValueProvider Protocol

  public var valueType: Any.Type {
    Vector1D.self
  }

  public var storage: ValueProviderStorage<Vector1D> {
    if let block = block {
      return .closure { frame in
        self.hasUpdate = false
        return Vector1D(Double(block(frame)))
      }
    } else {
      hasUpdate = false
      return .singleValue(Vector1D(Double(float)))
    }
  }

  public func hasUpdate(frame _: CGFloat) -> Bool {
    if block != nil {
      return true
    }
    return hasUpdate
  }

  // MARK: Private

  private var hasUpdate: Bool = true

  private var block: CGFloatValueBlock?
}
