//
//  PointValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import CoreGraphics
import Foundation
/// A `ValueProvider` that returns a CGPoint Value
public final class PointValueProvider: AnyValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping PointValueBlock) {
    self.block = block
    point = .zero
  }

  /// Initializes with a single point.
  public init(_ point: CGPoint) {
    self.point = point
    block = nil
    hasUpdate = true
  }

  // MARK: Public

  /// Returns a CGPoint for a CGFloat(Frame Time)
  public typealias PointValueBlock = (CGFloat) -> CGPoint

  public var point: CGPoint {
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
    let newPoint: CGPoint
    if let block = block {
      newPoint = block(frame)
    } else {
      newPoint = point
    }
    return newPoint.vector3dValue
  }

  // MARK: Private

  private var hasUpdate: Bool = true

  private var block: PointValueBlock?
}
