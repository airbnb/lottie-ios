//
//  BundleTests.swift
//  LottieTests
//
//  Created by Marcelo Fabri on 5/5/22.
//

import XCTest

@testable import Lottie

final class BundleTests: XCTestCase {

  var bundle: Bundle { .module }

  func testGetAnimationDataWithSuffix() throws {
    let data = try bundle.getAnimationData("HamburgerArrow.json", subdirectory: "Samples")
    XCTAssertNotNil(data)
  }

  func testGetAnimationDataWithoutSuffix() throws {
    let data = try bundle.getAnimationData("HamburgerArrow", subdirectory: "Samples")
    XCTAssertNotNil(data)
  }
}
