import XCTest

@testable import Lottie

@MainActor
final class AnimationReadyTests: XCTestCase {

    func testLottieAnimationViewPlayFailure() {
        let animationView = setupAnimationView()
        XCTAssertFalse(animationView.isAnimationPlaying)

        animationView.play()
        XCTAssertFalse(animationView.isAnimationPlaying)
        XCTAssertNil(animationView.animation)
    }

    func testAnimationReadyExpectedBehavior() {
        let animationView = setupAnimationView()
        XCTAssertFalse(animationView.isAnimationPlaying)

        animationView.onAnimationReady { view in
            animationView.play()
            XCTAssertTrue(animationView.isAnimationPlaying)
            XCTAssertNotNil(animationView.animation)
        }
    }

    @discardableResult
    private func setupAnimationView(dotLottieFilename: String = "animation_external_image") -> LottieAnimationView {
        let animationView = LottieAnimationView(dotLottieName: dotLottieFilename)
        animationView.frame.size = CGSize(width: 100, height: 100)
        animationView.layoutIfNeeded()
      return animationView
    }
}
