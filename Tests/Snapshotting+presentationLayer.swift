// Created by Cal Stephens on 12/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

#if os(iOS)
import SnapshotTesting
import UIKit
import XCTest

extension Snapshotting where Value == UIView, Format == UIImage {
  /// Captures an image of the input `UIView`'s `layer.presentation()`,
  /// which reflects the current state of any in-flight animations.
  static func imageOfPresentationLayer(
    precision: Float = 1,
    traits: UITraitCollection = .init())
    -> Snapshotting<UIView, UIImage>
  {
    // Use the SnapshotTesting framework's base `SimplySnapshot.image`
    // implementation for creating and diffing image files
    SimplySnapshotting.image(precision: precision, scale: traits.displayScale)
      // Convert the input `UIView` into a `UIImage`
      // by creating and then rendering its `layer.presentation()`
      .pullback { (view: UIView) -> UIImage in
        // Place the view in an on-screen window and then
        // have Core Animation update the screen synchronously
        let window = UIWindow()
        window.bounds = view.bounds
        window.isHidden = false
        window.addSubview(view)

        // Calling CATransaction.flush() makes Core Animation synchronously update
        // the content being displayed on-screen, which gives our view a presentation layer.
        CATransaction.flush()

        // Now that the view is on-screen, it has a presentation layer:
        guard let presentationLayer = view.layer.presentation() else {
          fatalError("Presentation layer does not exist and cannot be snapshot")
        }

        let image = UIGraphicsImageRenderer(bounds: view.bounds).image { context in
          presentationLayer.render(in: context.cgContext)
        }

        return image
      }
  }
}
#endif
