//
//  ValueProvidersTests.swift
//  LottieTests
//
//  Created by Marcelo Fabri on 5/5/22.
//

import Lottie
import XCTest

final class ValueProvidersTests: XCTestCase {

  func testGetValue() throws {
    let animationView = try XCTUnwrap(SnapshotConfiguration.makeAnimationView(
      for: "HamburgerArrow",
      configuration: .init(renderingEngine: .mainThread)))

    let keypath = AnimationKeypath(keypath: "A1.Shape 1.Stroke 1.Color")
    animationView.setValueProvider(ColorValueProvider(.red), keypath: keypath)
    let updatedColor = try XCTUnwrap(animationView.getValue(for: keypath, atFrame: 0) as? Color)
    XCTAssertEqual(updatedColor, .red)

    let originalColor = try XCTUnwrap(animationView.getOriginalValue(for: keypath, atFrame: 0) as? Color)
    XCTAssertEqual(originalColor, Color(r: 0.4, g: 0.16, b: 0.7, a: 1))
  }

}
