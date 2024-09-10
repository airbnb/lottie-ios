//
//  ValueProvidersTests.swift
//  LottieTests
//
//  Created by Marcelo Fabri on 5/5/22.
//

import XCTest
@testable import Lottie

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

  func testValueProviderStore() async throws {
    let optionalAnimationView = await SnapshotConfiguration.makeAnimationView(
      for: "HamburgerArrow",
      configuration: .init(renderingEngine: .mainThread))
    let animation = try XCTUnwrap(optionalAnimationView?.animation)

    let store = ValueProviderStore(logger: .printToConsole)
    let animationContext = LayerAnimationContext(
      animation: animation,
      timingConfiguration: .init(),
      startFrame: 0,
      endFrame: 100,
      valueProviderStore: store,
      compatibilityTracker: .init(mode: .track, logger: .printToConsole),
      logger: .printToConsole,
      loggingState: LoggingState(),
      currentKeypath: .init(keys: []),
      textProvider: DictionaryTextProvider([:]))

    // Test that the store returns the expected value for the provider.
    store.setValueProvider(ColorValueProvider(.red), keypath: "**.Color")
    let keyFramesQuery1 = try store.customKeyframes(
      of: .color,
      for: "Layer.Shape Group.Stroke 1.Color",
      context: animationContext)
    XCTAssertEqual(keyFramesQuery1?.keyframes.map(\.value.components), [[1, 0, 0, 1]])

    // Test a different provider/keypath.
    store.setValueProvider(ColorValueProvider(.blue), keypath: "A1.Shape 1.Stroke 1.Color")
    let keyFramesQuery2 = try store.customKeyframes(
      of: .color,
      for: "A1.Shape 1.Stroke 1.Color",
      context: animationContext)
    XCTAssertEqual(keyFramesQuery2?.keyframes.map(\.value.components), [[0, 0, 1, 1]])

    // Test that adding a different keypath didn't disrupt the original one.
    let keyFramesQuery3 = try store.customKeyframes(
      of: .color,
      for: "Layer.Shape Group.Stroke 1.Color",
      context: animationContext)
    XCTAssertEqual(keyFramesQuery3?.keyframes.map(\.value.components), [[1, 0, 0, 1]])

    // Test overriding the original keypath with a new provider stores the new provider.
    store.setValueProvider(ColorValueProvider(.black), keypath: "**.Color")
    let keyFramesQuery4 = try store.customKeyframes(
      of: .color,
      for: "Layer.Shape Group.Stroke 1.Color",
      context: animationContext)
    XCTAssertEqual(keyFramesQuery4?.keyframes.map(\.value.components), [[0, 0, 0, 1]])

    // Test removing specific keypath
    let keypathToRemove: AnimationKeypath = "**.Color"
    store.setValueProvider(ColorValueProvider(.black), keypath: keypathToRemove)
    store.removeValueProvider(for: keypathToRemove)
    let keyFramesQuery5 = try store.customKeyframes(
      of: .color,
      for: "Layer.Shape Group.Stroke 1.Color",
      context: animationContext)
    XCTAssertNil(keyFramesQuery5)

    // Test removing wildcard keypath
    store.setValueProvider(ColorValueProvider(.black), keypath: "**1.Color")
    store.removeValueProvider(for: "**.Color")
    let keyFramesQuery6 = try store.customKeyframes(
      of: .color,
      for: "Layer.Shape Group.Stroke 1.Color",
      context: animationContext)
    XCTAssertNil(keyFramesQuery6)
  }
}
