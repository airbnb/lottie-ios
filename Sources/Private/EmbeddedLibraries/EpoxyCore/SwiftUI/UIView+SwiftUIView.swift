#if !os(macOS)
// Created by eric_horacek on 3/3/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - UIViewProtocol + swiftUIView

extension UIViewProtocol {
  /// Returns a SwiftUI `View` representing this `UIView`, constructed with the given `makeView`
  /// closure and sized with the given sizing configuration.
  ///
  /// To perform additional configuration of the `UIView` instance, call `configure` on the
  /// returned SwiftUI `View`:
  /// ```
  /// MyUIView.swiftUIView(…)
  ///   .configure { context in
  ///     context.view.doSomething()
  ///   }
  /// ```
  ///
  /// To configure the sizing behavior of the `UIView` instance, call `sizing` on the returned
  /// SwiftUI `View`:
  /// ```
  /// MyView.swiftUIView(…).sizing(.intrinsicSize)
  /// ```
  /// The sizing defaults to `.automatic`.
  @available(iOS 13.0, tvOS 13.0, *)
  internal static func swiftUIView(makeView: @escaping () -> Self) -> SwiftUIUIView<Self, Void> {
    SwiftUIUIView(makeContent: makeView)
  }
}

// MARK: - UIViewProtocol

/// A protocol that all `UIView`s conform to, enabling extensions that have a `Self` reference.
internal protocol UIViewProtocol: UIView { }

// MARK: - UIView + UIViewProtocol

extension UIView: UIViewProtocol { }
#endif
