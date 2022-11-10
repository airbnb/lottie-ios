import XCTest

@testable import Lottie

@MainActor
final class AnimationReadyTests: XCTestCase {

    func testAnimationReadyExpectedBehavior() {
        let animationView = setupAnimationView(dotLottieFilename: "animation_external_image")
        XCTAssertFalse(animationView.isAnimationPlaying)

        animationView.onAnimationReady { view in
            animationView.play()
            XCTAssertTrue(animationView.isAnimationPlaying)
            XCTAssertNotNil(animationView.animation)
        }

        animationView.play()
        // This is not expected behavior
        XCTAssertFalse(animationView.isAnimationPlaying)
        XCTAssertNil(animationView.animation)
    }

    @discardableResult
    private func setupAnimationView(dotLottieFilename: String) -> LottieAnimationView {
        let animationView = LottieAnimationView(dotLottieName: dotLottieFilename)
        animationView.frame.size = CGSize(width: 100, height: 100)
        animationView.layoutIfNeeded()
      return animationView
    }
}
