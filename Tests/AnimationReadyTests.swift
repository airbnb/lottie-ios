import XCTest

@testable import Lottie

@MainActor
final class AnimationReadyTests: XCTestCase {

  // MARK: Internal

  func test_dotLottieFile_hasAnimation_onInitialize() {
    XCTExpectFailure("This is expected failure due to loading delay")
    let animationView = prepareDotLottieAnimationView()
    XCTAssertNotNil(animationView.animation)
  }

  func test_dotLottieFile_hasAnimation_onAnimationReady() {
    let exp = XCTestExpectation(description: "onAnimationReady expectation")

    let animationView = prepareDotLottieAnimationView()
    animationView.onAnimationReady { _ in
      XCTAssertNotNil(animationView.animation)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 0.5)
  }

  func test_jsonFile_hasAnimation_onInitialize() {
    let animationView = prepareJsonAnimationView()
    XCTAssertNotNil(animationView.animation)
  }

  func test_jsonFile_hasAnimation_onAnimationReady() {
    let exp = XCTestExpectation(description: "onAnimationReady expectation")

    let animationView = prepareJsonAnimationView()
    animationView.onAnimationReady { _ in
      XCTAssertNotNil(animationView.animation)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 0.5)
  }

  // MARK: Private

  private func prepareDotLottieAnimationView(filename: String = "animation_inline_image") -> LottieAnimationView {
    guard
      let fileUrl = Bundle.module.fileURLs(in: Samples.directoryName, withSuffix: "lottie")
        .first(where: { $0.lastPathComponent.hasPrefix(filename) }) else
    {
      XCTFail("Lottie file not found: \(filename)")
      return LottieAnimationView()
    }

    let animationView = LottieAnimationView(dotLottieFilePath: fileUrl.path)
    animationView.frame.size = CGSize(width: 100, height: 100)
    animationView.layoutIfNeeded()
    return animationView
  }

  private func prepareJsonAnimationView(filename: String = "Boat_Loader") -> LottieAnimationView {
    guard
      let fileUrl = Bundle.module.fileURLs(in: Samples.directoryName, withSuffix: "json")
        .first(where: { $0.lastPathComponent.hasPrefix(filename) }) else
    {
      XCTFail("Json file not found: \(filename)")
      return LottieAnimationView()
    }
    let animationView = LottieAnimationView(filePath: fileUrl.path)
    animationView.frame.size = CGSize(width: 100, height: 100)
    animationView.layoutIfNeeded()
    return animationView
  }
}
