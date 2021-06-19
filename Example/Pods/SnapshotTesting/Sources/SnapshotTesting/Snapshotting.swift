import Foundation
import XCTest

/// A type representing the ability to transform a snapshottable value into a diffable format (like text or an image) for snapshot testing.
public struct Snapshotting<Value, Format> {
  /// The path extension applied to references saved to disk.
  public var pathExtension: String?

  /// How the snapshot format is diffed and converted to and from data.
  public var diffing: Diffing<Format>

  /// How a value is transformed into a diffable snapshot format.
  public var snapshot: (Value) -> Async<Format>

  /// Creates a snapshot strategy.
  ///
  /// - Parameters:
  ///   - pathExtension: The path extension applied to references saved to disk.
  ///   - diffing: How to diff and convert the snapshot format to and from data.
  ///   - snapshot: An asynchronous transform function from a value into a diffable snapshot format.
  ///   - value: A value to be converted.
  public init(
    pathExtension: String?,
    diffing: Diffing<Format>,
    asyncSnapshot: @escaping (_ value: Value) -> Async<Format>
    ) {
    self.pathExtension = pathExtension
    self.diffing = diffing
    self.snapshot = asyncSnapshot
  }

  /// Creates a snapshot strategy.
  ///
  /// - Parameters:
  ///   - pathExtension: The path extension applied to references saved to disk.
  ///   - diffing: How to diff and convert the snapshot format to and from data.
  ///   - snapshot: A transform function from a value into a diffable snapshot format.
  ///   - value: A snapshot value to be converted.
  public init(
    pathExtension: String?,
    diffing: Diffing<Format>,
    snapshot: @escaping (_ value: Value) -> Format
    ) {
    self.init(pathExtension: pathExtension, diffing: diffing) {
      Async(value: snapshot($0))
    }
  }

  /// Transforms a strategy on `Value`s into a strategy on `NewValue`s through a function `(NewValue) -> Value`.
  ///
  /// This is the most important operation for transforming existing strategies into new strategies. It allows you to transform a `Snapshotting<Value, Format>` into a `Snapshotting<NewValue, Format>` by pulling it back along a function `(NewValue) -> Value`. Notice that the function must go in the direction `(NewValue) -> Value` even though we are transforming in the other direction `(Snapshotting<Value, Format>) -> Snapshotting<NewValue, Format>`.
  ///
  /// A simple example of this is to `pullback` the snapshot strategy on `UIView`s to work on `UIViewController`s:
  ///
  ///     let strategy = Snapshotting<UIView, UIImage>.image.pullback { (vc: UIViewController) in
  ///       return vc.view
  ///     }
  ///
  /// Here we took the strategy that snapshots `UIView`s as `UIImage`s and pulled it back to work on `UIViewController`s by using the function `(UIViewController) -> UIView` that simply plucks the view out of the controller.
  ///
  /// Nearly every snapshot strategy provided in this library is a pullback of some base strategy, which shows just how important this operation is.
  ///
  /// - Parameters:
  ///   - transform: A transform function from `NewValue` into `Value`.
  ///   - otherValue: A value to be transformed.
  public func pullback<NewValue>(_ transform: @escaping (_ otherValue: NewValue) -> Value) -> Snapshotting<NewValue, Format> {
    return self.asyncPullback { newValue in Async(value: transform(newValue)) }
  }

  /// Transforms a strategy on `Value`s into a strategy on `NewValue`s through a function `(NewValue) -> Async<Value>`.
  ///
  /// See the documention of `pullback` for a full description of how pullbacks works. This operation differs from `pullback` in that it allows you to use a transformation `(NewValue) -> Async<Value>`, which is necessary when your transformation needs to perform some asynchronous work.
  ///
  /// - Parameters:
  ///   - transform: A transform function from `NewValue` into `Async<Value>`.
  ///   - otherValue: A value to be transformed.
  public func asyncPullback<NewValue>(_ transform: @escaping (_ otherValue: NewValue) -> Async<Value>)
    -> Snapshotting<NewValue, Format> {

      return Snapshotting<NewValue, Format>(
        pathExtension: self.pathExtension,
        diffing: self.diffing
      ) { newValue in
        return .init { callback in
          transform(newValue).run { value in
            self.snapshot(value).run { snapshot in
              callback(snapshot)
            }
          }
        }
      }
  }
}

/// A snapshot strategy where the type being snapshot is also a diffable type.
public typealias SimplySnapshotting<Format> = Snapshotting<Format, Format>

extension Snapshotting where Value == Format {
  public init(pathExtension: String?, diffing: Diffing<Format>) {
    self.init(
      pathExtension: pathExtension,
      diffing: diffing,
      snapshot: { $0 }
    )
  }
}
