// Created for a fix verifying that Repeater `startOpacity`/`endOpacity` are
// applied by the Core Animation rendering engine.

import QuartzCore
import XCTest

@testable import Lottie

@MainActor
final class RepeaterOpacityTests: XCTestCase {

  /// A `Repeater` with `startOpacity: 100` and `endOpacity: 0` should linearly interpolate
  /// each copy's opacity from 100% (first copy) to 0% (last copy).
  func testRepeaterAppliesStartAndEndOpacity() throws {
    let animation = try XCTUnwrap(try? LottieAnimation.from(data: Self.repeaterAnimationJSON))

    let animationLayer = try CoreAnimationLayer(
      animation: animation,
      imageProvider: BundleImageProvider(bundle: Bundle.main, searchPath: nil),
      textProvider: DefaultTextProvider(),
      fontProvider: DefaultFontProvider(),
      maskAnimationToBounds: true,
      compatibilityTrackerMode: .track,
      logger: .shared
    )

    animationLayer.bounds = CGRect(origin: .zero, size: animation.size)
    animationLayer.layoutIfNeeded()
    animationLayer.display()

    let repeaterLayers = Self.findRepeaterLayers(in: animationLayer)
    XCTAssertEqual(repeaterLayers.count, 4, "Expected 4 repeater copies")

    // Copy 0 -> startOpacity (100%), copy 3 -> endOpacity (0%), copies 1/2 interpolated in between.
    let expectedOpacities: [Float] = [1.0, 2.0 / 3.0, 1.0 / 3.0, 0.0]
    for (index, layer) in repeaterLayers.enumerated() {
      XCTAssertEqual(
        layer.opacity,
        expectedOpacities[index],
        accuracy: 0.001,
        "Repeater copy \(index) has incorrect opacity"
      )
    }
  }

  // MARK: Private

  /// Recursively finds all `RepeaterLayer`s in the given layer's sublayer tree,
  /// in the order they were added (matching repeater copy index).
  private static func findRepeaterLayers(in layer: CALayer) -> [RepeaterLayer] {
    var found = [RepeaterLayer]()
    for sublayer in layer.sublayers ?? [] {
      if let repeaterLayer = sublayer as? RepeaterLayer {
        found.append(repeaterLayer)
      }
      found.append(contentsOf: findRepeaterLayers(in: sublayer))
    }
    return found
  }

  /// A minimal shape layer with a single `Repeater` (4 copies, so: 100, eo: 0)
  private static let repeaterAnimationJSON = """
  {
    "v": "5.7.0", "fr": 30, "ip": 0, "op": 30, "w": 100, "h": 100, "nm": "RepeaterOpacityTest",
    "layers": [
      {
        "ind": 1, "ty": 4, "nm": "ring", "sr": 1,
        "ks": {
          "o": { "a": 0, "k": 100 },
          "r": { "a": 0, "k": 0 },
          "p": { "a": 0, "k": [50, 50] },
          "a": { "a": 0, "k": [0, 0] },
          "s": { "a": 0, "k": [100, 100] }
        },
        "shapes": [
          {
            "ty": "gr", "nm": "leaf",
            "it": [
              { "ty": "sh", "nm": "Path 1", "ks": { "a": 0, "k": { "i": [[0,0],[0,0]], "o": [[0,0],[0,0]], "v": [[-10,-10],[10,10]], "c": true } } },
              { "ty": "fl", "nm": "fill", "c": { "a": 0, "k": [0, 1, 0] }, "o": { "a": 0, "k": 100 } },
              { "ty": "tr", "o": { "a": 0, "k": 100 }, "r": { "a": 0, "k": 0 }, "p": { "a": 0, "k": [0, 0] }, "a": { "a": 0, "k": [0, 0] }, "s": { "a": 0, "k": [100, 100] } }
            ]
          },
          {
            "ty": "rp", "nm": "Repeater 1", "c": { "a": 0, "k": 4 }, "o": { "a": 0, "k": 0 }, "m": 1,
            "tr": {
              "p": { "a": 0, "k": [0, 0] }, "a": { "a": 0, "k": [0, 0] }, "s": { "a": 0, "k": [100, 100] },
              "r": { "a": 0, "k": 0 }, "so": { "a": 0, "k": 100 }, "eo": { "a": 0, "k": 0 }
            }
          }
        ],
        "ip": 0, "op": 30, "st": 0
      }
    ]
  }
  """.data(using: .utf8)!

}
