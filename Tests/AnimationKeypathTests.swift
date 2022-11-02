// Created by Cal Stephens on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

@testable import Lottie

@MainActor
final class AnimationKeypathTests: XCTestCase {

  // MARK: Internal

  func testKeypathMatches() {
    let keypath = AnimationKeypath(keypath: "Layer.Shape Group.Stroke 1.Color")

    XCTAssertTrue(keypath.matches("Layer.Shape Group.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("**.Color"))
    XCTAssertTrue(keypath.matches("**.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("**.Shape Group.Stroke 1.Color"))
    XCTAssertTrue(keypath.matches("Layer.**.Color"))
    XCTAssertTrue(keypath.matches("Layer.Shape Group.*.Color"))
    XCTAssertTrue(keypath.matches("Layer.*.*.Color"))

    XCTAssertFalse(keypath.matches("Layer.*.Color"))
    XCTAssertFalse(keypath.matches("**.Layer.Shape Group.Stroke 1.Color"))
    XCTAssertFalse(keypath.matches("*.Layer.Shape Group.Stroke 1.Color"))
    XCTAssertFalse(keypath.matches("Layer.Shape Group.Stroke 1.Color.*"))
    XCTAssertFalse(keypath.matches("Layer.Shape Group.Stroke 1.Color.**"))
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

  func testMainThreadEngineKeypathLogging() async {
    await snapshotHierarchyKeypaths(
      animationName: "Switch",
      configuration: LottieConfiguration(renderingEngine: .mainThread))
  }

  func testCoreAnimationEngineKeypathLogging() async {
    await snapshotHierarchyKeypaths(
      animationName: "Switch",
      configuration: LottieConfiguration(renderingEngine: .coreAnimation))

    await snapshotHierarchyKeypaths(
      animationName: "Issues/issue_1664",
      configuration: LottieConfiguration(renderingEngine: .coreAnimation))
  }

  /// The Core Animation engine supports a subset of the keypaths supported by the Main Thread engine.
  /// All keypaths that are supported in the Core Animation engine should also be supported by the Main Thread engine.
  func testCoreAnimationEngineKeypathCompatibility() async {
    let mainThreadKeypaths =
      Set(await hierarchyKeypaths(animationName: "Switch", configuration: .init(renderingEngine: .mainThread)))
    let coreAnimationKeypaths = await hierarchyKeypaths(
      animationName: "Switch",
      configuration: .init(renderingEngine: .coreAnimation))

    for coreAnimationKeypath in coreAnimationKeypaths {
      XCTAssert(
        mainThreadKeypaths.contains(coreAnimationKeypath),
        """
        \(coreAnimationKeypath) from Core Animation rendering engine \
        is not supported in Main Thread rendering engine
        """)
    }
  }

  // MARK: Private

  private func snapshotHierarchyKeypaths(
    animationName: String,
    configuration: LottieConfiguration,
    function: String = #function,
    line: UInt = #line) async
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
    var printedMessages = [String]()
    let logger = LottieLogger(info: { message in
      printedMessages.append(message())
    })

    let animationView = await SnapshotConfiguration.makeAnimationView(
      for: animationName,
      configuration: configuration,
      logger: logger)
    animationView?.logHierarchyKeypaths()
    return Array(printedMessages[1...])
  }

}
