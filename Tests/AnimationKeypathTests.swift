// Created by Cal Stephens on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import XCTest

@testable import Lottie

final class AnimationKeypathTests: XCTestCase {

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

}
