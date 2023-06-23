// Created by eric_horacek on 10/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - View

extension View {
  /// Applies the layout margins from the parent `EpoxySwiftUIHostingView` to this `View`, if there
  /// are any.
  ///
  /// Can be used to have a background in SwiftUI underlap the safe area within a bar installer, for
  /// example.
  ///
  /// These margins are propagated via the `EnvironmentValues.epoxyLayoutMargins`.
  public func epoxyLayoutMargins() -> some View {
    modifier(EpoxyLayoutMarginsPadding())
  }
}

// MARK: - EnvironmentValues

extension EnvironmentValues {
  /// The layout margins of the parent `EpoxySwiftUIHostingView`, else zero if there is none.
  public var epoxyLayoutMargins: EdgeInsets {
    get { self[EpoxyLayoutMarginsKey.self] }
    set { self[EpoxyLayoutMarginsKey.self] = newValue }
  }
}

// MARK: - EpoxyLayoutMarginsKey

private struct EpoxyLayoutMarginsKey: EnvironmentKey {
  static let defaultValue = EdgeInsets()
}

// MARK: - EpoxyLayoutMarginsPadding

/// A view modifier that applies the layout margins from an enclosing `EpoxySwiftUIHostingView` to
/// the modified `View`.
private struct EpoxyLayoutMarginsPadding: ViewModifier {
  @Environment(\.epoxyLayoutMargins) var epoxyLayoutMargins

  func body(content: Content) -> some View {
    content.padding(epoxyLayoutMargins)
  }
}
