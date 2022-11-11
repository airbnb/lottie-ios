// Created by Cal Stephens on 11/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import XCTest

@MainActor
final class AnimationViewTests: XCTestCase {

  func loadJsonFile() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .module,
      subdirectory: Samples.directoryName)

    XCTAssertNotNil(animationView.animation)
  }

  func loadDotLottieFileAsync() async throws {
    let animationView = try await LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .module,
      subdirectory: Samples.directoryName)

    XCTAssertNotNil(animationView.animation)
  }

  func loadDotLottieFileAsyncWithClosure() {
    let expectation = XCTestExpectation(description: "DotLottie file is loaded asynchronously")

    let animationView = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .module,
      subdirectory: Samples.directoryName,
      completion: { animationView, error in
        XCTAssertNil(error)
        XCTAssertNotNil(animationView.animation)
        expectation.fulfill()
      })

    XCTAssertNil(animationView.animation)
    wait(for: [expectation], timeout: 1.0)
  }

}
