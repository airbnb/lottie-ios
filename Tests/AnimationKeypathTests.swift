// Created by Cal Stephens on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

@testable import Lottie

@MainActor
final class AnimationKeypathTests: XCTestCase {

  // MARK: Internal

  /// All of the sample animations with custom value providers defined in `SnapshotConfiguration.swift`
  /// should also participate in more in-depth tests for `AnimationKeypath` generation.
  var animationKeypathTestAnimations: [String] {
    Samples.sampleAnimationNames.filter { sampleAnimationName in
      !SnapshotConfiguration.forSample(named: sampleAnimationName).customValueProviders.isEmpty
    }
  }

  func testMainThreadEngineKeypathLogging() async {
    for animationKeypathTestAnimation in animationKeypathTestAnimations {
      await snapshotHierarchyKeypaths(
        animationName: animationKeypathTestAnimation,
        configuration: LottieConfiguration(renderingEngine: .mainThread))
    }
  }

  func testCoreAnimationEngineKeypathLogging() async {
    for animationKeypathTestAnimation in animationKeypathTestAnimations {
      await snapshotHierarchyKeypaths(
        animationName: animationKeypathTestAnimation,
        configuration: LottieConfiguration(renderingEngine: .coreAnimation))
    }
  }

  func testKeypathMatches() {
    let keypath = AnimationKeypath(keypath: "Layer.Shape Group.Stroke 1.Color")

    XCTAssertTrue(keypath.matches("Layer.Shape Group.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("**.Color"))
    XCTAssertTrue(keypath.matches("**.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("**.Shape Group.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("Layer.**.Color"))
    XCTAssertTrue(keypath.matches("Layer.Shape Group.*.Color"))
    XCTAssertTrue(keypath.matches("Layer.*.*.Color"))
    XCTAssertTrue(keypath.matches("**"))
    XCTAssertTrue(keypath.matches("Layer.**"))
    XCTAssertTrue(keypath.matches("Layer.**.Color"))
    XCTAssertTrue(keypath.matches("Layer.**.Shape Group.**"))
    XCTAssertTrue(keypath.matches("**.Layer.Shape Group.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("**.Layer.Shape Group.Stroke 1.**.Color"))

    XCTAssertFalse(keypath.matches("Layer.*.Color"))
    XCTAssertFalse(keypath.matches("*.Layer.Shape Group.Stroke 1.Color"))
    XCTAssertFalse(keypath.matches("*.Layer.Shape Group.Stroke 1.*.Color"))
    XCTAssertFalse(keypath.matches("Layer.Shape Group.Stroke 1.Color.*"))
    XCTAssertFalse(keypath.matches("Layer.Shape Group.Stroke 1.Color.**"))

    let keypath2 = AnimationKeypath(keypath: "pin.Group 1.fill-primary.Color")
    XCTAssertTrue(keypath2.matches("**.*primary.**.Color"))
    XCTAssertTrue(keypath2.matches("**.*primary.Color"))
    XCTAssertFalse(keypath2.matches("*primary.**.Color"))

    let keypath3 = AnimationKeypath(keypath: "fill-primary.Stroke 1.Color")
    XCTAssertTrue(keypath3.matches("**.*primary.**.Color"))
    XCTAssertFalse(keypath3.matches("**.*primary.Color"))
    XCTAssertTrue(keypath3.matches("*primary.**.Color"))

    let keypath4 = AnimationKeypath(keypath: "Ellipse 1-composition.Ellipse 1-stroke.Ellipse 1-stroke.Stroke 1.Color")
    XCTAssertTrue(keypath4.matches("**.Stroke 1.**.Color"))
    XCTAssertTrue(keypath4.matches("**.Stroke 1.Color"))
    XCTAssertFalse(keypath4.matches("**.Stroke 1.*.Color"))
  }

  func testLayerForKeypath() {
    let animationView = LottieAnimationView(
      animation: Samples.animation(named: "Boat_Loader"),
      configuration: LottieConfiguration(renderingEngine: .mainThread))

    XCTAssertNotNil(animationView.animationLayer?.layer(for: "Success.FishComplete.Fish1Tail 7"))
    XCTAssertNotNil(animationView.animationLayer?.layer(for: "Success.FishComplete"))
    XCTAssertNotNil(animationView.animationLayer?.layer(for: "Success"))
    XCTAssertNotNil(animationView.animationLayer?.layer(for: "Success.*.Fish1Tail 7"))
  }

  /// The Core Animation engine supports a subset of the keypaths supported by the Main Thread engine.
  /// All keypaths that are supported in the Core Animation engine should also be supported by the Main Thread engine.
  func testCoreAnimationEngineKeypathCompatibility() async {
    for animationName in animationKeypathTestAnimations {
      let mainThreadKeypaths = Set(await hierarchyKeypaths(
        animationName: animationName,
        configuration: .init(renderingEngine: .mainThread)))

      let coreAnimationKeypaths = await hierarchyKeypaths(
        animationName: animationName,
        configuration: .init(renderingEngine: .coreAnimation))

      for coreAnimationKeypath in coreAnimationKeypaths {
        XCTAssert(
          mainThreadKeypaths.contains(coreAnimationKeypath),
          """
          [\(animationName)] "\(coreAnimationKeypath)" from Core Animation rendering engine \
          is not supported in Main Thread rendering engine
          """)
      }
    }
  }

  override func setUp() {
    LottieLogger.shared = .printToConsole
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
  }

  // MARK: Private

  private func snapshotHierarchyKeypaths(
    animationName: String,
    configuration: LottieConfiguration,
    function: String = #function,
    line: UInt = #line)
    async
  {
    let hierarchyKeypaths = await hierarchyKeypaths(animationName: animationName, configuration: configuration)

    assertSnapshot(
      matching: hierarchyKeypaths.sorted().joined(separator: "\n"),
      as: .description,
      named: animationName,
      testName: function,
      line: line)
  }

  private func hierarchyKeypaths(animationName: String, configuration: LottieConfiguration) async -> [String] {
    let animationView = await SnapshotConfiguration.makeAnimationView(
      for: animationName,
      configuration: configuration)
    return animationView?.allHierarchyKeypaths() ?? []
  }

}
