// Created by Cal Stephens on 1/28/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `CombinedShapeItem` to this `CALayer`
  @nonobjc
  func addAnimations(
    for combinedShapes: CombinedShapeItem,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: combinedShapes.shapes.keyframes,
      value: { paths in
        let combinedPath = CGMutablePath()
        for path in paths {
          combinedPath.addPath(path.cgPath())
        }
        return combinedPath
      },
      context: context)
  }
}

// MARK: - CombinedShapeItem

/// A custom `ShapeItem` subclass that combines multiple `Shape`s into a single `KeyframeGroup`
final class CombinedShapeItem: ShapeItem {

  // MARK: Lifecycle

  init(shapes: KeyframeGroup<[BezierPath]>, name: String) {
    self.shapes = shapes
    super.init(name: name, type: .shape, hidden: false)
  }

  required init(from _: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }

  // MARK: Internal

  let shapes: KeyframeGroup<[BezierPath]>

}
