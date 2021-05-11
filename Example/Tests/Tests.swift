import SnapshotTesting
import XCTest

@testable import Lottie

class Tests: XCTestCase {
  let animationView = AnimationView()

  override func setUp() {
    super.setUp()

    animationView.contentMode = .scaleAspectFit
  }

  func testLottieLogo() {
    let animation = Animation.named("LottieLogo1", subdirectory: "TestAnimations")
    animationView.animation = animation

    animationView.currentProgress = 0.1
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))

    animationView.currentProgress = 0.25
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))

    animationView.currentProgress = 0.5
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))

    animationView.currentProgress = 0.75
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))

    animationView.currentProgress = 0.9
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))

    animationView.currentProgress = 1.0
    assertSnapshot(matching: animationView, as: .image(size: CGSize(width: 500, height: 500)))
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
}
