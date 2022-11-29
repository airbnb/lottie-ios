// Created by Cal Stephens on 11/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import XCTest

@MainActor
final class AnimationViewTests: XCTestCase {

  func testLoadJsonFile() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .module,
      subdirectory: Samples.directoryName)

    XCTAssertNotNil(animationView.animation)

    let expectation = XCTestExpectation(description: "animationLoaded is called")
    animationView.animationLoaded = { [weak animationView] view, animation in
      XCTAssert(animation === view.animation)
      XCTAssertEqual(view, animationView)
      XCTAssert(Thread.isMainThread)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.25)
  }

  func testLoadDotLottieFileAsyncWithCompletionClosure() {
    let expectation = XCTestExpectation(description: "completion closure is called")

    _ = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .module,
      subdirectory: Samples.directoryName,
      completion: { animationView, error in
        XCTAssertNil(error)
        XCTAssertNotNil(animationView.animation)
        XCTAssert(Thread.isMainThread)
        expectation.fulfill()
      })

    wait(for: [expectation], timeout: 1.0)
  }

  func testLoadDotLottieFileAsyncWithDidLoadClosure() {
    let expectation = XCTestExpectation(description: "animationLoaded closure is called")

    let animationView = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .module,
      subdirectory: Samples.directoryName)

    animationView.animationLoaded = { [weak animationView] view, animation in
      XCTAssert(view.animation === animation)
      XCTAssertEqual(view, animationView)
      XCTAssert(Thread.isMainThread)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

}
