//
//  ValueProvidersTests.swift
//  LottieTests
//
//  Created by Marcelo Fabri on 5/5/22.
//

import Lottie
import XCTest

@MainActor
final class ValueProvidersTests: XCTestCase {

  func testGetValue() async throws {
    let optionalAnimationView = await SnapshotConfiguration.makeAnimationView(
      for: "HamburgerArrow",
      configuration: .init(renderingEngine: .mainThread))

    let animationView = try XCTUnwrap(optionalAnimationView)

    let keypath = AnimationKeypath(keypath: "A1.Shape 1.Stroke 1.Color")
    animationView.setValueProvider(ColorValueProvider(.red), keypath: keypath)
    let updatedColor = try XCTUnwrap(animationView.getValue(for: keypath, atFrame: 0) as? LottieColor)
    XCTAssertEqual(updatedColor, .red)

    let originalColor = try XCTUnwrap(animationView.getOriginalValue(for: keypath, atFrame: 0) as? LottieColor)
    XCTAssertEqual(originalColor, LottieColor(r: 0.4, g: 0.16, b: 0.7, a: 1))
  }

}
