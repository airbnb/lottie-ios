// Created by Cal Stephens on 11/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import XCTest

@MainActor
final class AnimationViewTests: XCTestCase {

  override func setUp() async throws {
    LottieLogger.shared = .printToConsole
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
  }

  func testLoadJsonFile() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .lottie,
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
      bundle: .lottie,
      subdirectory: Samples.directoryName,
      completion: { animationView, error in
        XCTAssertNil(error)
        XCTAssertNotNil(animationView.animation)
        XCTAssert(Thread.isMainThread)
        expectation.fulfill()
      })

    XCTExpectFailure("This test case has been flaky in CI", strict: false) {
      wait(for: [expectation], timeout: 1.0)
    }
  }

  func testLoadDotLottieFileAsyncWithDidLoadClosure() {
    let expectation = XCTestExpectation(description: "animationLoaded closure is called")

    let animationView = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .lottie,
      subdirectory: Samples.directoryName)

    animationView.animationLoaded = { [weak animationView] view, animation in
      XCTAssert(view.animation === animation)
      XCTAssertEqual(view, animationView)
      XCTAssert(Thread.isMainThread)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testPlayFromFrameToFrame() {
    XCTExpectFailure("Realtime animation playback tests are flaky in CI", strict: false) {
      let tests: [(fromFrame: AnimationFrameTime?, toFrame: AnimationFrameTime)] = [
        (fromFrame: nil, toFrame: 10),
        (fromFrame: 8, toFrame: 14),
        (fromFrame: 14, toFrame: 0),
      ]

      let engineOptions: [(label: String, engine: RenderingEngineOption)] = [
        ("mainThread", .mainThread),
        ("coreAnimation", .coreAnimation),
        ("automatic", .automatic),
      ]

      let animationSupportedByCoreAnimationRenderingEngine = LottieAnimation.named(
        "Issues/issue_1877",
        bundle: .lottie,
        subdirectory: Samples.directoryName)

      let animationUnsupportedByCoreAnimationRenderingEngine = LottieAnimation.named(
        "TypeFace/G",
        bundle: .lottie,
        subdirectory: Samples.directoryName)

      let animations = [
        animationSupportedByCoreAnimationRenderingEngine,
        animationUnsupportedByCoreAnimationRenderingEngine,
      ]

      for animation in animations {
        XCTAssertNotNil(animation)
        let window = UIWindow()

        for (test, values) in tests.enumerated() {
          for engine in engineOptions {
            let animationView = LottieAnimationView(
              animation: animation,
              configuration: .init(renderingEngine: engine.engine))

            window.addSubview(animationView)
            defer {
              animationView.removeFromSuperview()
            }

            let animationPlayingExpectation = XCTestExpectation(
              description: "Animation playing case \(test) on engine: \(engine.label)")

            let animationCompleteExpectation = XCTestExpectation(
              description: "Finished playing case \(test) on engine: \(engine.label)")

            animationView.play(fromFrame: values.fromFrame, toFrame: values.toFrame, loopMode: .playOnce) { finished in
              XCTAssertTrue(
                finished,
                "Failed case \(test) on engine: \(engine.label)")

              XCTAssertEqual(
                animationView.currentFrame,
                values.toFrame,
                accuracy: 0.01,
                "Failed case \(test) on engine: \(engine.label)")

              XCTAssertFalse(
                animationView.isAnimationPlaying,
                "Failed case \(test) on engine: \(engine.label)")

              animationCompleteExpectation.fulfill()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              animationPlayingExpectation.fulfill()

              // Verify that we're testing at least one case where .automatic falls back to the main thread engine
              if engine.engine == .automatic {
                if animation === animationUnsupportedByCoreAnimationRenderingEngine {
                  XCTAssertEqual(animationView.currentRenderingEngine, .mainThread)
                } else {
                  XCTAssertEqual(animationView.currentRenderingEngine, .coreAnimation)
                }
              }

              XCTAssertTrue(
                animationView.isAnimationPlaying,
                "Failed case \(test) on engine: \(engine.label)")

              // Check that the animation is playing in the correct direction:
              // After a brief delay we should be closer to the from frame than the to frame
              let distanceFromStartFrame = abs((values.fromFrame ?? 0) - animationView.realtimeAnimationFrame)
              let distanceFromEndFrame = abs(values.toFrame - animationView.realtimeAnimationFrame)
              XCTAssertTrue(
                distanceFromStartFrame < distanceFromEndFrame,
                "Failed case \(test) on engine: \(engine.label)")
            }

            wait(for: [animationPlayingExpectation, animationCompleteExpectation], timeout: 1.0)
          }
        }
      }
    }
  }

}
