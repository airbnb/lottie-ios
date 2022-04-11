// Created by Cal Stephens on 2/14/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation
import XCTest

@testable import Lottie

// MARK: - PerformanceTests

final class PerformanceTests: XCTestCase {

  // MARK: Internal

  func testAnimationViewSetup_simpleAnimation() {
    // Compare the performance of displaying this simple animation in the two animation engines
    let ratio = compareEngineSetupPerformance(for: simpleAnimation, iterations: 2000)

    // This is basically a snapshot test for the performance of the Core Animation engine
    // compared to the Main Thread engine. Currently, the Core Animation engine is
    // about the same speed as the Main Thread engine in this example.
    XCTAssertEqual(ratio, 1.0, accuracy: 0.35)
  }

  func testAnimationViewSetup_complexAnimation() {
    let ratio = compareEngineSetupPerformance(for: complexAnimation, iterations: 500)

    // The Core Animation engine is currently about 1.5x slower than the
    // Main Thread engine in this example.
    XCTAssertEqual(ratio, 1.5, accuracy: 0.6)
  }

  func testAnimationViewScrubbing_simpleAnimation() {
    let ratio = compareEngineScrubbingPerformance(for: simpleAnimation, iterations: 2000)
    XCTAssertEqual(ratio, 0.01, accuracy: 0.01)
  }

  func testAnimationViewScrubbing_complexAnimation() {
    let ratio = compareEngineScrubbingPerformance(for: complexAnimation, iterations: 2000)
    XCTAssertEqual(ratio, 0.01, accuracy: 0.01)
  }

  override func setUp() {
    TestHelpers.performanceTestsAreRunning = true
  }

  override func tearDown() {
    TestHelpers.performanceTestsAreRunning = false
  }

  // MARK: Private

  private let simpleAnimation = Animation.named(
    "loading_dots_1",
    bundle: .module,
    subdirectory: "Samples/LottieFiles")!

  private let complexAnimation = Animation.named(
    "LottieLogo2",
    bundle: .module,
    subdirectory: "Samples")!

  /// Compares initializing the given animation with both the Main Thread and Core Animation engine,
  /// and returns the ratio of how much slower the Core Animation is than the Main Thread engine
  private func compareEngineSetupPerformance(for animation: Animation, iterations: Int) -> Double {
    let mainThreadEnginePerformance = measurePerformance {
      for _ in 0..<iterations {
        // Each animation setup needs to be wrapped in its own `CATransaction`
        // in order for the layers to be deallocated immediately. Otherwise
        // the layers aren't deallocated until the end of the test run,
        // which causes memory usage to grow unbounded.
        CATransaction.begin()
        let animationView = setupAnimationView(with: animation, configuration: .init(renderingEngine: .mainThread))
        // Call `display()` on the layer to make sure any pending setup occurs immediately
        animationView.animationLayer!.display()
        CATransaction.commit()
      }
    }

    print("Main thread engine took \(mainThreadEnginePerformance) seconds")

    let coreAnimationEnginePerformance = measurePerformance {
      for _ in 0..<iterations {
        // Each animation setup needs to be wrapped in its own `CATransaction`
        // in order for the layers to be deallocated immediately. Otherwise
        // the layers aren't deallocated until the end of the test run,
        // which causes memory usage to grow unbounded.
        CATransaction.begin()
        let animationView = setupAnimationView(with: animation, configuration: .init(renderingEngine: .coreAnimation))
        // Call `display()` on the layer to make sure any pending setup occurs immediately
        animationView.animationLayer!.display()
        CATransaction.commit()
      }
    }

    print("Core Animation engine took \(coreAnimationEnginePerformance) seconds")

    let ratio = coreAnimationEnginePerformance / mainThreadEnginePerformance
    print("Core Animation engine took \(ratio)x as long as the Main Thread engine")
    return ratio
  }

  /// Compares performance of scrubbing the given animation with both the Main Thread and Core Animation engine,
  /// and returns the ratio of how much slower the Core Animation is than the Main Thread engine
  private func compareEngineScrubbingPerformance(for animation: Animation, iterations: Int) -> Double {
    let mainThreadAnimationView = setupAnimationView(with: animation, configuration: .init(renderingEngine: .mainThread))
    let mainThreadEnginePerformance = measurePerformance {
      for i in 0..<iterations {
        mainThreadAnimationView.currentProgress = Double(i) / Double(iterations)

        // Since the main thread engine only re-renders in `display()`, which is normally called by Core Animation,
        // we have to invoke it manually. This triggers the same code path that would happen when scrubbing in
        // a real use case.
        mainThreadAnimationView.animationLayer!.display()
      }
    }

    print("Main thread engine took \(mainThreadEnginePerformance) seconds")

    let coreAnimationView = setupAnimationView(with: animation, configuration: .init(renderingEngine: .coreAnimation))
    let coreAnimationEnginePerformance = measurePerformance {
      for i in 0..<iterations {
        coreAnimationView.currentProgress = Double(i) / Double(iterations)

        // Call `display()` on the layer to make sure any pending setup occurs immediately
        coreAnimationView.animationLayer!.display()
      }
    }

    print("Core Animation engine took \(coreAnimationEnginePerformance) seconds")

    let ratio = coreAnimationEnginePerformance / mainThreadEnginePerformance
    print("Core Animation engine took \(ratio)x as long as the Main Thread engine")
    return ratio
  }

  @discardableResult
  private func setupAnimationView(with animation: Animation, configuration: LottieConfiguration) -> AnimationView {
    let animationView = AnimationView(animation: animation, configuration: configuration)
    animationView.frame.size = CGSize(width: animation.width, height: animation.height)
    animationView.layoutIfNeeded()
    return animationView
  }

  private func measurePerformance(_ block : () -> Void) -> TimeInterval {
    let start = DispatchTime.now()
    block()
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Double(nanoTime) / 1_000_000_000
  }

}
