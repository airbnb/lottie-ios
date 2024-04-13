//
//  PointValueProvider.swift
//  lottie-swift
//
//  Created by Yuval Kalugny on 13/04/2024
//

import CoreGraphics
import Foundation

// MARK: - PathValueProvider

/// A `ValueProvider` that returns a CGPath Value
public final class PathValueProvider: ValueProvider {

  // MARK: Lifecycle

  /// Initializes with a block provider
  public init(block: @escaping PathValueBlock) {
    self.block = block
    path = .init(rect: .zero, transform: nil)
    identity = UUID()
  }

  /// Initializes with a single path.
  public init(_ path: CGPath) {
    self.path = path
    block = nil
    hasUpdate = true
    identity = path.hashValue
  }

  // MARK: Public

  /// Returns a CGPath for a CGFloat(Frame Time)
  public typealias PathValueBlock = (CGFloat) -> CGPath

  public var path: CGPath {
    didSet {
      hasUpdate = true
    }
  }

  // MARK: ValueProvider Protocol

  public var valueType: Any.Type {
    BezierPath.self
  }

  public var storage: ValueProviderStorage<BezierPath> {
    if let block {
      return .closure { frame in
        self.hasUpdate = false
        return block(frame).bezierPath
      }
    } else {
      hasUpdate = false
      return .singleValue(path.bezierPath)
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

  private var block: PathValueBlock?
  private let identity: AnyHashable
}

// MARK: Equatable

extension PathValueProvider: Equatable {
  public static func ==(_ lhs: PathValueProvider, _ rhs: PathValueProvider) -> Bool {
    lhs.identity == rhs.identity
  }
}
