//
//  AnimationConfigurationTests.swift
//  LottieTests
//
//  Created by YOUNGSUN on 8/25/25.
//

import XCTest

@testable import Lottie

final class AnimationConfigurationTests: XCTestCase {
  func testExpectedDuration() {
    let context = AnimationContext(playFrom: 0, playTo: 60, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: false, repeatCount: 1, speed: 1, timeOffset: 0)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 2.0, accuracy: 0.0001)
  }

  func testExpectedDuration_withAutoreverse() {
    let context = AnimationContext(playFrom: 0, playTo: 60, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: true, repeatCount: 1, speed: 1, timeOffset: 0)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 4.0, accuracy: 0.0001)
  }

  func testExpectedDuration_withRepeats() {
    let context = AnimationContext(playFrom: 0, playTo: 60, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: false, repeatCount: 3, speed: 1, timeOffset: 0)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 6.0, accuracy: 0.0001)
  }

  func testExpectedDuration_withSpeed() {
    let context = AnimationContext(playFrom: 0, playTo: 60, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: false, repeatCount: 1, speed: 2, timeOffset: 0)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 1.0, accuracy: 0.0001)
  }

  func testExpectedDuration_withAutoreverse_withRepeats_withSpeed() {
    let context = AnimationContext(playFrom: 0, playTo: 60, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: true, repeatCount: 3, speed: 2, timeOffset: 0)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 6.0, accuracy: 0.0001)
  }

  func testExpectedDuration_ComplexContext() {
    let context = AnimationContext(playFrom: 30, playTo: 300, framerate: 30, closure: nil)
    let timing = CoreAnimationLayer.CAMediaTimingConfiguration(autoreverses: true, repeatCount: 3, speed: 2, timeOffset: 2)
    let config = CoreAnimationLayer.AnimationConfiguration(
      animationContext: context,
      timingConfiguration: timing,
      recordHierarchyKeypath: nil
    )

    XCTAssertEqual(config.expectedAnimationDuration, 25.0, accuracy: 0.0001)
  }
}
