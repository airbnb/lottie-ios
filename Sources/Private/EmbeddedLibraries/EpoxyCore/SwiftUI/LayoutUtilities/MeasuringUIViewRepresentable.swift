// Created by eric_horacek on 6/22/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

// MARK: - MeasuringUIViewRepresentable

/// A `UIViewRepresentable` that uses a `SwiftUIMeasurementContainer` wrapping its represented
/// `UIView` to report its size that fits a proposed size to SwiftUI.
///
/// Supports iOS 13-15 using the private `_overrideSizeThatFits(…)` method and iOS 16+ using the
/// `sizeThatFits(…)` method.
///
/// - SeeAlso: ``SwiftUIMeasurementContainer``
public protocol MeasuringUIViewRepresentable: UIViewRepresentable
  where
  UIViewType == SwiftUIMeasurementContainer<Content>
{
  /// The `UIView` content that's being measured by the enclosing `SwiftUIMeasurementContainer`.
  associatedtype Content: UIView

  /// The sizing strategy of the represented view.
  ///
  /// To configure the sizing behavior of the `View` instance, call `sizing` on this `View`, e.g.:
  /// ```
  /// myView.sizing(.intrinsicSize)
  /// ```
  var sizing: SwiftUIMeasurementContainerStrategy { get set }
}

// MARK: Extensions

extension MeasuringUIViewRepresentable {
  /// Returns a copy of this view with its sizing strategy updated to the given `sizing` value.
  public func sizing(_ strategy: SwiftUIMeasurementContainerStrategy) -> Self {
    var copy = self
    copy.sizing = strategy
    return copy
  }
}

// MARK: Defaults

extension MeasuringUIViewRepresentable {
  public func _overrideSizeThatFits(
    _ size: inout CGSize,
    in proposedSize: _ProposedSize,
    uiView: UIViewType)
  {
    uiView.strategy = sizing

    // Note: this method is not double-called on iOS 16, so we don't need to do anything to prevent
    // extra work here.
    let children = Mirror(reflecting: proposedSize).children

    // Creates a `CGSize` by replacing `nil`s with `UIView.noIntrinsicMetric`
    uiView.proposedSize = .init(
      width: children.first { $0.label == "width" }?.value as? CGFloat ?? UIView.noIntrinsicMetric,
      height: children.first { $0.label == "height" }?.value as? CGFloat ?? UIView.noIntrinsicMetric)

    size = uiView.measuredFittingSize
  }

  #if swift(>=5.7) // Proxy check for being built with the iOS 15 SDK
  @available(iOS 16.0, *)
  public func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: UIViewType,
    context _: Context)
    -> CGSize?
  {
    uiView.strategy = sizing

    // Creates a size by replacing `nil`s with `UIView.noIntrinsicMetric`
    uiView.proposedSize = .init(
      width: proposal.width ?? UIView.noIntrinsicMetric,
      height: proposal.height ?? UIView.noIntrinsicMetric)

    return uiView.measuredFittingSize
  }
  #endif
}
