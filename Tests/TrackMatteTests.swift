// Copyright © 2026 Airbnb Inc. All rights reserved.

import XCTest

@testable import Lottie

// MARK: - TrackMatteTests

/// Tests for track mattes referenced explicitly through `tp` (`LayerModel.matteParent`)
/// and flagged through `td` (`LayerModel.isMatteTarget`).
@MainActor
final class TrackMatteTests: XCTestCase {

  // MARK: Internal

  func testDecodesMatteParentAndMatteTargetFromDictionary() throws {
    let animation = try animation(nonAdjacentMatteAnimation)
    let (mattedLayer, _, matteSource) = try layers(of: animation)

    XCTAssertEqual(mattedLayer.matte, .add)
    XCTAssertEqual(mattedLayer.matteParent, 2)
    XCTAssertFalse(mattedLayer.isMatteTarget)

    XCTAssertNil(matteSource.matte)
    XCTAssertNil(matteSource.matteParent)
    XCTAssertTrue(matteSource.isMatteTarget)
  }

  func testDecodesMatteParentAndMatteTargetFromCodable() throws {
    let animation = try animation(nonAdjacentMatteAnimation, strategy: .legacyCodable)
    let (mattedLayer, _, matteSource) = try layers(of: animation)

    XCTAssertEqual(mattedLayer.matteParent, 2)
    XCTAssertTrue(matteSource.isMatteTarget)
  }

  /// `td` is specified as a 0-1 integer, but some authoring tools emit a boolean instead
  func testDecodesBooleanMatteTarget() throws {
    var animation = nonAdjacentMatteAnimation
    var layers = try XCTUnwrap(animation["layers"] as? [[String: Any]])
    layers[2]["td"] = true
    animation["layers"] = layers

    XCTAssertTrue(try self.animation(animation, strategy: .legacyCodable).layers[2].isMatteTarget)
    XCTAssertTrue(try self.animation(animation, strategy: .dictionaryBased).layers[2].isMatteTarget)
  }

  func testDefaultsToNoMatteParentOrMatteTarget() throws {
    let animation = try animation(adjacentMatteAnimation)

    for layer in animation.layers {
      XCTAssertNil(layer.matteParent)
      XCTAssertFalse(layer.isMatteTarget)
    }
  }

  /// The matte source is resolved through `tp` even when it isn't adjacent to the
  /// layer that references it, and is never rendered on its own.
  ///  - https://github.com/airbnb/lottie-ios/issues/2702
  func testResolvesTrackMatteReferencedByMatteParent() throws {
    let animation = try animation(nonAdjacentMatteAnimation)
    let paired = animation.layers.reversed().pairedLayersAndMattes()

    XCTAssertEqual(paired.map(\.layer.name), ["Unrelated", "Masked"])
    XCTAssertEqual(paired.last?.matte?.model.name, "Matte Source")
    XCTAssertEqual(paired.last?.matte?.matteType, .add)
  }

  /// Without `tp`, the matte is the layer directly above the matted layer in the layer list
  func testFallsBackToAdjacentLayerWithoutMatteParent() throws {
    let animation = try animation(adjacentMatteAnimation)
    let paired = animation.layers.reversed().pairedLayersAndMattes()

    XCTAssertEqual(paired.map(\.layer.name), ["Unrelated", "Masked"])
    XCTAssertEqual(paired.last?.matte?.model.name, "Matte Source")
  }

  /// A `tp` reference that doesn't correspond to any layer falls back to adjacency
  func testFallsBackToAdjacentLayerWhenMatteParentIsUnknown() throws {
    var animation = adjacentMatteAnimation
    var layerDictionaries = try XCTUnwrap(animation["layers"] as? [[String: Any]])
    layerDictionaries[1]["tp"] = 99
    animation["layers"] = layerDictionaries

    let paired = try self.animation(animation).layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Unrelated", "Masked"])
    XCTAssertEqual(paired.last?.matte?.model.name, "Matte Source")
  }

  /// A run of consecutive matted layers pairs up two at a time, rather than
  /// each layer becoming the matte of the layer behind it.
  func testConsecutiveMattedLayersPairUpTwoAtATime() throws {
    // Listed front to back, so each matte source sits directly above the layer it masks
    let animation = try animation(animationDictionary(layers: [
      solidLayer(index: 1, name: "Matte Source 1"),
      solidLayer(index: 2, name: "Masked 1", matte: 1),
      solidLayer(index: 3, name: "Matte Source 2"),
      solidLayer(index: 4, name: "Masked 2", matte: 1),
    ]))

    let paired = animation.layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Masked 2", "Masked 1"])
    XCTAssertEqual(paired.map { $0.matte?.model.name }, ["Matte Source 2", "Matte Source 1"])
  }

  /// A layer can only be used as the matte of a single other layer
  func testMatteSourceIsNotSharedBetweenLayers() throws {
    let animation = try animation(animationDictionary(layers: [
      solidLayer(index: 1, name: "Masked 1", matte: 1, matteParent: 3),
      solidLayer(index: 2, name: "Masked 2", matte: 1, matteParent: 3),
      solidLayer(index: 3, name: "Matte Source", isMatteTarget: true),
    ]))

    let paired = animation.layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Masked 2", "Masked 1"])
    // The matte source is claimed by the first layer to reference it in z-axis order
    XCTAssertEqual(paired.map { $0.matte?.model.name }, ["Matte Source", nil])
  }

  /// A layer flagged with `td` isn't rendered on its own, even if the layer
  /// that referenced it was dropped while building the layer hierarchy.
  func testMatteTargetIsNotRenderedWhenUnreferenced() throws {
    let animation = try animation(animationDictionary(layers: [
      solidLayer(index: 1, name: "Unrelated"),
      solidLayer(index: 2, name: "Matte Source", isMatteTarget: true),
    ]))

    let paired = animation.layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Unrelated"])
  }

  func testLayerWithoutMatteIsUnaffected() throws {
    let animation = try animation(animationDictionary(layers: [
      solidLayer(index: 1, name: "Front"),
      solidLayer(index: 2, name: "Back"),
    ]))

    let paired = animation.layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Back", "Front"])
    XCTAssertEqual(paired.compactMap { $0.matte }.count, 0)
  }

  /// A layer can't be its own matte
  func testSelfReferentialMatteParentIsIgnored() throws {
    let animation = try animation(animationDictionary(layers: [
      solidLayer(index: 1, name: "Masked", matte: 1, matteParent: 1),
      solidLayer(index: 2, name: "Unrelated"),
    ]))

    let paired = animation.layers.reversed().pairedLayersAndMattes()
    XCTAssertEqual(paired.map(\.layer.name), ["Unrelated", "Masked"])
    XCTAssertNil(paired.last?.matte)
  }

  func testMainThreadEngineDoesNotRenderMatteSource() throws {
    let animation = try animation(nonAdjacentMatteAnimation)
    let animationLayer = MainThreadAnimationLayer(
      animation: animation,
      imageProvider: BundleImageProvider(bundle: .main, searchPath: nil),
      textProvider: DefaultTextProvider(),
      fontProvider: DefaultFontProvider(),
      maskAnimationToBounds: true,
      logger: .shared
    )

    let layersByName = Dictionary(
      uniqueKeysWithValues: animationLayer.animationLayers.map { ($0.name ?? "", $0) }
    )
    let mattedLayer = try XCTUnwrap(layersByName["Masked"])
    let matteSource = try XCTUnwrap(layersByName["Matte Source"])

    XCTAssertTrue(mattedLayer.matteLayer === matteSource)
    XCTAssertTrue(mattedLayer.mask === matteSource, "The matte source should be applied as a mask")
    XCTAssertEqual(
      animationLayer.sublayers?.compactMap(\.name),
      ["Unrelated", "Masked"],
      "The matte source should not be rendered on its own"
    )
    XCTAssertEqual(matteSource.bounds, animation.bounds, "The matte source should still be laid out")
  }

  func testCoreAnimationEngineDoesNotRenderMatteSource() throws {
    let animation = try animation(nonAdjacentMatteAnimation)
    let rootLayer = CALayer()
    try rootLayer.setupLayerHierarchy(
      for: animation.layers,
      context: LayerContext(
        animation: animation,
        imageProvider: BundleImageProvider(bundle: .main, searchPath: nil),
        textProvider: DefaultTextProvider(),
        fontProvider: DefaultFontProvider(),
        compatibilityTracker: CompatibilityTracker(mode: .track, logger: .shared),
        layerName: "root layer"
      )
    )

    XCTAssertFalse(
      layerNames(in: rootLayer, includingMasks: false).contains("Matte Source"),
      "The matte source should not be rendered on its own"
    )
    XCTAssertTrue(
      layerNames(in: rootLayer, includingMasks: true).contains("Matte Source"),
      "The matte source should be applied as a mask"
    )
    XCTAssertTrue(layerNames(in: rootLayer, includingMasks: false).contains("Unrelated"))
    XCTAssertTrue(layerNames(in: rootLayer, includingMasks: false).contains("Masked"))
  }

  // MARK: Private

  /// The layer providing the matte is referenced by `tp` and is neither adjacent to,
  /// nor above, the layer that references it.
  private var nonAdjacentMatteAnimation: [String: Any] {
    animationDictionary(layers: [
      solidLayer(index: 1, name: "Masked", matte: 1, matteParent: 2),
      solidLayer(index: 3, name: "Unrelated"),
      solidLayer(index: 2, name: "Matte Source", isMatteTarget: true),
    ])
  }

  /// The layer providing the matte is directly above the layer it masks, and `tp` is omitted
  private var adjacentMatteAnimation: [String: Any] {
    animationDictionary(layers: [
      solidLayer(index: 2, name: "Matte Source"),
      solidLayer(index: 1, name: "Masked", matte: 1),
      solidLayer(index: 3, name: "Unrelated"),
    ])
  }

  /// Parses the given animation JSON, going through `JSONSerialization` so that both
  /// decoding strategies receive the same values they would for a real animation file.
  private func animation(
    _ dictionary: [String: Any],
    strategy: DecodingStrategy = .dictionaryBased
  ) throws -> LottieAnimation {
    let data = try JSONSerialization.data(withJSONObject: dictionary)
    return try LottieAnimation.from(data: data, strategy: strategy)
  }

  /// The layers of `nonAdjacentMatteAnimation`, in the order they're listed in the animation
  private func layers(of animation: LottieAnimation) throws -> (LayerModel, LayerModel, LayerModel) {
    XCTAssertEqual(animation.layers.count, 3)
    return (animation.layers[0], animation.layers[1], animation.layers[2])
  }

  private func layerNames(in layer: CALayer, includingMasks: Bool) -> [String] {
    var names = [layer.name].compactMap { $0 }

    for sublayer in layer.sublayers ?? [] {
      names += layerNames(in: sublayer, includingMasks: includingMasks)
    }

    if includingMasks, let mask = layer.mask {
      names += layerNames(in: mask, includingMasks: includingMasks)
    }

    return names
  }

  private func solidLayer(
    index: Int,
    name: String,
    matte: Int? = nil,
    matteParent: Int? = nil,
    isMatteTarget: Bool = false
  ) -> [String: Any] {
    var layer: [String: Any] = [
      "ty": 1,
      "ind": index,
      "nm": name,
      "ip": 0,
      "op": 60,
      "st": 0,
      "sw": 100,
      "sh": 100,
      "sc": "#ff0000",
    ]

    if let matte { layer["tt"] = matte }
    if let matteParent { layer["tp"] = matteParent }
    if isMatteTarget { layer["td"] = 1 }

    return layer
  }

  private func animationDictionary(layers: [[String: Any]]) -> [String: Any] {
    [
      "v": "5.7.0",
      "fr": 60,
      "ip": 0,
      "op": 60,
      "w": 100,
      "h": 100,
      "layers": layers,
    ]
  }

}
