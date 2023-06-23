// Created by matthew_cheok on 11/19/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - EpoxyIntrinsicContentSizeInvalidator

/// Allows the SwiftUI view contained in an Epoxy model to request the invalidation of
/// the container's intrinsic content size.
///
/// ```
/// @Environment(\.epoxyIntrinsicContentSizeInvalidator) var invalidateIntrinsicContentSize
///
/// var body: some View {
///   ...
///   .onChange(of: size) {
///     invalidateIntrinsicContentSize()
///   }
/// }
/// ```
public struct EpoxyIntrinsicContentSizeInvalidator {
  let invalidate: () -> Void

  public func callAsFunction() {
    invalidate()
  }
}

// MARK: - EnvironmentValues

extension EnvironmentValues {
  /// A means of invalidating the intrinsic content size of the parent `EpoxySwiftUIHostingView`.
  public var epoxyIntrinsicContentSizeInvalidator: EpoxyIntrinsicContentSizeInvalidator {
    get { self[EpoxyIntrinsicContentSizeInvalidatorKey.self] }
    set { self[EpoxyIntrinsicContentSizeInvalidatorKey.self] = newValue }
  }
}

// MARK: - EpoxyIntrinsicContentSizeInvalidatorKey

private struct EpoxyIntrinsicContentSizeInvalidatorKey: EnvironmentKey {
  static let defaultValue = EpoxyIntrinsicContentSizeInvalidator(invalidate: { })
}
