// Created by Cal Stephens on 9/12/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import UIKit
import XCTest

@testable import Lottie

// MARK: - TextProviderTests

@MainActor
final class TextProviderTests: XCTestCase {

  // MARK: Internal

  func testMainThreadTextProvider() async {
    await snapshotTextProviderCalls(
      animationName: "Issues/issue_1949_full_paths",
      configuration: LottieConfiguration(renderingEngine: .mainThread),
      textProvider: LoggingAnimationKeypathTextProvider())
  }

  func testMainThreadLegacyTextProvider() async {
    await snapshotTextProviderCalls(
      animationName: "Issues/issue_1949_full_paths",
      configuration: LottieConfiguration(renderingEngine: .mainThread),
      textProvider: LoggingLegacyAnimationTextProvider())
  }

  func testCoreAnimationTextProvider() async {
    await snapshotTextProviderCalls(
      animationName: "Issues/issue_1949_full_paths",
      configuration: LottieConfiguration(renderingEngine: .coreAnimation),
      textProvider: LoggingAnimationKeypathTextProvider())
  }

  func testCoreAnimationLegacyTextProvider() async {
    await snapshotTextProviderCalls(
      animationName: "Issues/issue_1949_full_paths",
      configuration: LottieConfiguration(renderingEngine: .coreAnimation),
      textProvider: LoggingLegacyAnimationTextProvider())
  }

  // MARK: Private

  private func snapshotTextProviderCalls(
    animationName: String,
    configuration: LottieConfiguration,
    textProvider: LoggingTextProvider,
    function: String = #function,
    line: UInt = #line)
    async
  {
    let textProviderCalls = await textProviderCalls(
      animationName: animationName,
      configuration: configuration,
      textProvider: textProvider)

    assertSnapshot(
      matching: textProviderCalls.sorted().joined(separator: "\n"),
      as: .description,
      named: animationName,
      testName: function,
      line: line)
  }

  private func textProviderCalls(
    animationName: String,
    configuration: LottieConfiguration,
    textProvider: LoggingTextProvider)
    async -> [String]
  {
    let animationView = await SnapshotConfiguration.makeAnimationView(
      for: animationName,
      configuration: configuration,
      customSnapshotConfiguration: .customTextProvider(textProvider))!

    animationView.forceDisplayUpdate()

    return textProvider.methodCalls
  }
}

// MARK: - LoggingTextProvider

protocol LoggingTextProvider: AnimationKeypathTextProvider {
  var methodCalls: [String] { get }
}

// MARK: - LoggingLegacyAnimationTextProvider

/// A `LegacyAnimationTextProvider` that logs all of the calls to its `textFor` method
private final class LoggingLegacyAnimationTextProvider: LegacyAnimationTextProvider, LoggingTextProvider {

  // MARK: Lifecycle

  init() { }

  // MARK: Internal

  var methodCalls: [String] = []

  func textFor(keypathName: String, sourceText: String) -> String {
    methodCalls.append("textFor(keypathName: \"\(keypathName)\", sourceText: \"\(sourceText)\")")
    return sourceText
  }

}

// MARK: - LoggingAnimationKeypathTextProvider

/// A `LegacyAnimationTextProvider` that logs all of the calls to its `textFor` method
private final class LoggingAnimationKeypathTextProvider: AnimationKeypathTextProvider, LoggingTextProvider {

  // MARK: Lifecycle

  init() { }

  // MARK: Internal

  var methodCalls: [String] = []

  func text(for keypath: AnimationKeypath, sourceText: String) -> String? {
    let keypathString = keypath.keys.joined(separator: ".")
    methodCalls.append("text(for: \"\(keypathString)\", sourceText: \"\(sourceText)\")")
    return nil
  }
}
