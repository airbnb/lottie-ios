//
//  SizeValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation

/// A `ValueProvider` that returns a CGSize Value
public final class SizeValueProvider: AnyValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping SizeValueBlock) {
    self.block = block
    size = .zero
  }

  /// Initializes with a single size.
  public init(_ size: CGSize) {
    self.size = size
    block = nil
    hasUpdate = true
  }

  // MARK: Public

  /// Returns a CGSize for a CGFloat(Frame Time)
  public typealias SizeValueBlock = (CGFloat) -> CGSize

  public var size: CGSize {
    didSet {
      hasUpdate = true
    }
  }

  // MARK: ValueProvider Protocol

  public var valueType: Any.Type {
    Vector3D.self
  }

  public func hasUpdate(frame _: CGFloat) -> Bool {
    if block != nil {
      return true
    }
    return hasUpdate
  }

  public func value(frame: CGFloat) -> Any {
    hasUpdate = false
    let newSize: CGSize
    if let block = block {
      newSize = block(frame)
    } else {
      newSize = size
    }
    return newSize.vector3dValue
  }

  // MARK: Private

  private var hasUpdate: Bool = true

  private var block: SizeValueBlock?
}
