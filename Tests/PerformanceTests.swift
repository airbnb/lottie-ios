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
    let ratio = compareEngineSetupPerformance(
      of: .mainThread,
      with: .coreAnimation,
      for: simpleAnimation,
      iterations: 2000)

    // This is basically a snapshot test for the performance of the Core Animation engine
    // compared to the Main Thread engine. Currently, the Core Animation engine is
    // about the same speed as the Main Thread engine in this example.
    XCTAssertEqual(ratio, 1.0, accuracy: 0.35)
  }

  func testAnimationViewSetup_complexAnimation() {
    // Compare the performance of displaying this simple animation in the two animation engines
    let ratio = compareEngineSetupPerformance(
      of: .mainThread,
      with: .coreAnimation,
      for: complexAnimation,
      iterations: 500)

    // The Core Animation engine is currently about 1.5x slower than the
    // Main Thread engine in this example.
    XCTAssertEqual(ratio, 1.5, accuracy: 0.6)
  }

  func testAnimationViewSetup_automaticEngine() {
    // Compare the performance of displaying this simple animation with the core animation engine
    // vs with the automatic engine option
    let ratio = compareEngineSetupPerformance(
      of: .coreAnimation,
      with: .automatic,
      for: simpleAnimation,
      iterations: 2000)

    // The automatic engine option should have the same performance as the core animation engine,
    // when rendering an animation supported by the CA engine.
    XCTAssertEqual(ratio, 1.0, accuracy: 0.5)
  }

  func testAnimationViewScrubbing_simpleAnimation() {
    let ratio = compareEngineScrubbingPerformance(for: simpleAnimation, iterations: 2000)
    XCTAssertEqual(ratio, 0.01, accuracy: 0.01)
  }

  func testAnimationViewScrubbing_complexAnimation() {
    let ratio = compareEngineScrubbingPerformance(for: complexAnimation, iterations: 2000)
    XCTAssertEqual(ratio, 0.01, accuracy: 0.01)
  }

  func testParsing_simpleAnimation() throws {
    let data = try XCTUnwrap(Bundle.module.getAnimationData("loading_dots_1", subdirectory: "Samples/LottieFiles"))
    let ratio = try compareDeserializationPerformance(data: data, iterations: 2000)
    XCTAssertEqual(ratio, 2, accuracy: 0.65)
  }

  func testParsing_complexAnimation() throws {
    let data = try XCTUnwrap(Bundle.module.getAnimationData("LottieLogo2", subdirectory: "Samples"))
    let ratio = try compareDeserializationPerformance(data: data, iterations: 500)
    XCTAssertEqual(ratio, 1.7, accuracy: 0.6)
  }

  override func setUp() {
    TestHelpers.performanceTestsAreRunning = true
  }

  override func tearDown() {
    TestHelpers.performanceTestsAreRunning = false
  }

  // MARK: Private

  private let simpleAnimation = LottieAnimation.named(
    "loading_dots_1",
    bundle: .module,
    subdirectory: "Samples/LottieFiles")!

  private let complexAnimation = LottieAnimation.named(
    "LottieLogo2",
    bundle: .module,
    subdirectory: "Samples")!

  /// Compares initializing the given animation with the two given engines,
  /// and returns the ratio of how much slower engine B is than engine A.
  private func compareEngineSetupPerformance(
    of engineA: RenderingEngineOption,
    with engineB: RenderingEngineOption,
    for animation: LottieAnimation,
    iterations: Int)
    -> Double
  {
    let engineAPerformance = measurePerformance {
      for _ in 0..<iterations {
        setUpAndTearDownAnimationView(with: animation, configuration: .init(renderingEngine: engineA))
      }
    }

    LottieLogger.shared.info("\(engineA) engine took \(engineAPerformance) seconds")

    let engineBPerformance = measurePerformance {
      for _ in 0..<iterations {
        setUpAndTearDownAnimationView(with: animation, configuration: .init(renderingEngine: engineB))
      }
    }

    LottieLogger.shared.info("\(engineB) engine took \(engineBPerformance) seconds")

    let ratio = engineBPerformance / engineAPerformance
    LottieLogger.shared.info("\(engineB) engine took \(ratio)x as long as \(engineA) engine")
    return ratio
  }

  private func setUpAndTearDownAnimationView(with animation: LottieAnimation, configuration: LottieConfiguration) {
    // Each animation setup needs to be wrapped in its own `CATransaction`
    // in order for the layers to be deallocated immediately. Otherwise
    // the layers aren't deallocated until the end of the test run,
    // which causes memory usage to grow unbounded.
    CATransaction.begin()
    let animationView = setupAnimationView(with: animation, configuration: configuration)
    // Call `display()` on the layer to make sure any pending setup occurs immediately
    animationView.animationLayer!.display()
    CATransaction.commit()

    /// The view / layer is deallocated when the transaction is flushed
    CATransaction.flush()
  }

  /// Compares performance of scrubbing the given animation with both the Main Thread and Core Animation engine,
  /// and returns the ratio of how much slower the Core Animation is than the Main Thread engine
  private func compareEngineScrubbingPerformance(for animation: LottieAnimation, iterations: Int) -> Double {
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

    LottieLogger.shared.info("Main thread engine took \(mainThreadEnginePerformance) seconds")

    let coreAnimationView = setupAnimationView(with: animation, configuration: .init(renderingEngine: .coreAnimation))
    let coreAnimationEnginePerformance = measurePerformance {
      for i in 0..<iterations {
        coreAnimationView.currentProgress = Double(i) / Double(iterations)

        // Call `display()` on the layer to make sure any pending setup occurs immediately
        coreAnimationView.animationLayer!.display()
      }
    }

    LottieLogger.shared.info("Core Animation engine took \(coreAnimationEnginePerformance) seconds")

    let ratio = coreAnimationEnginePerformance / mainThreadEnginePerformance
    LottieLogger.shared.info("Core Animation engine took \(ratio)x as long as the Main Thread engine")
    return ratio
  }

  private func compareDeserializationPerformance(data: Data, iterations: Int) throws -> Double {
    let codablePerformance = try measurePerformance {
      for _ in 0..<iterations {
        _ = try LottieAnimation.from(data: data, strategy: .codable)
      }
    }

    LottieLogger.shared.info("Codable deserialization took \(codablePerformance) seconds")

    let dictPerformance = try measurePerformance {
      for _ in 0..<iterations {
        _ = try LottieAnimation.from(data: data, strategy: .dictionaryBased)
      }
    }

    LottieLogger.shared.info("DictionaryBased deserialization took \(dictPerformance) seconds")
    let ratio = codablePerformance / dictPerformance
    LottieLogger.shared.info("Codable deserialization took \(ratio)x as long as DictionaryBased")
    return ratio
  }

  @discardableResult
  private func setupAnimationView(with animation: LottieAnimation, configuration: LottieConfiguration) -> LottieAnimationView {
    let animationView = LottieAnimationView(animation: animation, configuration: configuration)
    animationView.frame.size = CGSize(width: animation.width, height: animation.height)
    animationView.layoutIfNeeded()
    return animationView
  }

  private func measurePerformance(_ block : () throws -> Void) rethrows -> TimeInterval {
    let start = DispatchTime.now()
    try block()
    let end = DispatchTime.now()
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Double(nanoTime) / 1_000_000_000
  }

}
