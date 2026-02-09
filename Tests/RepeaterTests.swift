import XCTest
import SnapshotTesting
@testable import Lottie

@MainActor
final class RepeaterTests: XCTestCase {

  override func invokeTest() {
    #if os(iOS)
    super.invokeTest()
    #endif
  }

  func testMainThreadRepeater() throws {
    // 1. Load the sample animation
    let bundle = Bundle(for: type(of: self))
    let resourceURL = bundle.url(forResource: "repeater_test", withExtension: "json", subdirectory: "Samples")
    let fileURL = resourceURL ?? URL(fileURLWithPath: "Tests/Samples/repeater_test.json")
    let animation = try XCTUnwrap(LottieAnimation.filepath(fileURL.path), "Could not load repeater_test.json")

    // 2. Setup AnimationView with Main Thread engine
    let config = LottieConfiguration(renderingEngine: .mainThread)
    let animationView = LottieAnimationView(animation: animation, configuration: config)
    animationView.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
    animationView.currentProgress = 0.5
    animationView.layoutIfNeeded()

    // 3. Verify via Snapshot
    assertSnapshot(
      matching: animationView,
      as: .image(precision: 0.99),
      named: "MainThread_Repeater_Default"
    )
  }
}
