// Created by Cal Stephens on 12/27/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

@testable import Lottie

@MainActor
final class CompatibleAnimationViewTests: XCTestCase {
  func testCompatibleAnimationView() throws {
    guard try SnapshotTests.enabled else { return }

    #if os(iOS)
    let animation = CompatibleAnimation(name: "LottieLogo2", subdirectory: Samples.directoryName, bundle: .lottie)
    let animationView = CompatibleAnimationView(compatibleAnimation: animation)
    animationView.frame.size = animation.animation!.snapshotSize(for: .default)
    animationView.currentProgress = 0.5
    assertSnapshot(matching: animationView, as: .imageOfPresentationLayer())
    #endif
  }
}
