import Foundation
import XCTest

extension Snapshotting {
  /// Transforms an existing snapshot strategy into one that waits for some amount of time before taking the snapshot. This can be useful for waiting for animations to complete or for UIKit events to finish (i.e. waiting for a UINavigationController to push a child onto the stack).
  /// - Parameters:
  ///   - duration: The amount of time to wait before taking the snapshot.
  ///   - strategy: The snapshot to invoke after the specified amount of time has passed.
  public static func wait(
    for duration: TimeInterval,
    on strategy: Snapshotting
  ) -> Snapshotting {
    return Snapshotting(
      pathExtension: strategy.pathExtension,
      diffing: strategy.diffing,
      asyncSnapshot: { value in
        Async { callback in
          let expectation = XCTestExpectation(description: "Wait")
          DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            expectation.fulfill()
          }
          _ = XCTWaiter.wait(for: [expectation], timeout: duration + 1)
          strategy.snapshot(value).run(callback)
        }
    })
  }
}
