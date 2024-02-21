// Created by Bryn Bodayle on 1/24/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

// MARK: - SwiftUIMeasurementContainer

/// A view that has an `intrinsicContentSize` of the `uiView`'s `systemLayoutSizeFitting(…)` and
/// supports double layout pass sizing and content size category changes.
///
/// This container view uses an injected proposed width to measure the view and return its ideal
/// height through the `SwiftUISizingContext` binding.
///
/// - SeeAlso: ``MeasuringViewRepresentable``
public final class SwiftUIMeasurementContainer<Content: ViewType>: ViewType {

  // MARK: Lifecycle

  public init(content: Content, strategy: SwiftUIMeasurementContainerStrategy) {
    self.content = content
    self.strategy = strategy

    // On iOS 15 and below, passing zero can result in a constraint failure the first time a view
    // is displayed, but the system gracefully recovers afterwards. On iOS 16, it's fine to pass
    // zero.
    let initialSize: CGSize
    if #available(iOS 16, tvOS 16, macOS 13, *) {
      initialSize = .zero
    } else {
      initialSize = .init(width: 375, height: 150)
    }
    super.init(frame: .init(origin: .zero, size: initialSize))

    addSubview(content)
    setUpConstraints()
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  /// The  most recently measured fitting size of the `uiView` that fits within the current
  /// `proposedSize`.
  ///
  /// Contains `proposedSize`/`bounds.size` fallbacks for dimensions with no intrinsic size, as
  /// compared to `intrinsicContentSize` which has `UIView.noIntrinsicMetric` fields in the case of
  /// no intrinsic size.
  public var measuredFittingSize: CGSize {
    _measuredFittingSize ?? measureView()
  }

  /// The `UIView` content that's being measured by this container.
  public var content: Content {
    didSet {
      guard content !== oldValue else { return }
      oldValue.removeFromSuperview()
      addSubview(content)
      // Invalidate the strategy since it's derived from this view.
      _resolvedStrategy = nil
      // Re-configure the constraints since they depend on the resolved strategy.
      setUpConstraints()
      // Finally, we need to re-measure the view.
      _measuredFittingSize = nil
    }
  }

  /// The proposed size at the time of the latest measurement.
  ///
  /// Has a side-effect of updating the `measuredIntrinsicContentSize` if it's changed.
  public var proposedSize = CGSize.noIntrinsicMetric {
    didSet {
      guard oldValue != proposedSize else { return }
      _resolvedStrategy = nil

      // The proposed size is only used by the measurement, so just re-measure.
      _measuredFittingSize = nil
      setNeedsUpdateConstraintsForPlatform()
    }
  }

  /// The measurement strategy of this container.
  ///
  /// Has a side-effect of updating the `measuredIntrinsicContentSize` if it's changed.
  public var strategy: SwiftUIMeasurementContainerStrategy {
    didSet {
      guard oldValue != strategy else { return }
      // Invalidate the resolved strategy since it's derived from this strategy.
      _resolvedStrategy = nil
      // Then, re-measure the view.
      _measuredFittingSize = nil
    }
  }

  public override var intrinsicContentSize: CGSize {
    _intrinsicContentSize
  }

  #if os(macOS)
  public override func layout() {
    super.layout()

    // We need to re-measure the view whenever the size of the bounds changes, as the previous size
    // may now be incorrect.
    if latestMeasurementBoundsSize != nil, bounds.size != latestMeasurementBoundsSize {
      // This will trigger SwiftUI to re-measure the view.
      super.invalidateIntrinsicContentSize()
    }
  }
  #else
  public override func layoutSubviews() {
    super.layoutSubviews()

    // We need to re-measure the view whenever the size of the bounds changes, as the previous size
    // may now be incorrect.
    if latestMeasurementBoundsSize != nil, bounds.size != latestMeasurementBoundsSize {
      // This will trigger SwiftUI to re-measure the view.
      super.invalidateIntrinsicContentSize()
    }
  }
  #endif

  public override func invalidateIntrinsicContentSize() {
    super.invalidateIntrinsicContentSize()

    // Invalidate the resolved strategy in case it changes with the re-measurement as it relies on
    // the intrinsic size.
    _resolvedStrategy = nil
    _measuredFittingSize = nil
  }

  public override func updateConstraints() {
    updateSizeConstraints()
    super.updateConstraints()
  }

  // MARK: Private

  /// The most recently measured intrinsic content size of the `uiView`, else `noIntrinsicMetric` if
  /// it has not yet been measured.
  ///
  /// Contains `UIView.noIntrinsicMetric` fallbacks for dimensions with no intrinsic size,
  /// as compared to `measuredFittingSize` which has `proposedSize`/`bounds.size` fallbacks.
  private var _intrinsicContentSize = CGSize.noIntrinsicMetric

  /// The bounds size at the time of the latest measurement.
  private var latestMeasurementBoundsSize: CGSize?

  private var topConstraint: NSLayoutConstraint?
  private var leadingConstraint: NSLayoutConstraint?
  private var maxWidthConstraint: NSLayoutConstraint?
  private var fixedWidthConstraint: NSLayoutConstraint?
  private var fixedHeightConstraint: NSLayoutConstraint?

  /// The cached `resolvedStrategy` to prevent unnecessary re-measurements.
  private var _resolvedStrategy: ResolvedSwiftUIMeasurementContainerStrategy?

  /// The cached `measuredFittingSize` to prevent unnecessary re-measurements.
  private var _measuredFittingSize: CGSize? {
    didSet {
      setNeedsUpdateConstraintsForPlatform()
    }
  }

  /// The resolved measurement strategy.
  private var resolvedStrategy: ResolvedSwiftUIMeasurementContainerStrategy {
    if let resolvedStrategy = _resolvedStrategy {
      return resolvedStrategy
    }

    let resolved: ResolvedSwiftUIMeasurementContainerStrategy
    switch strategy {
    case .automatic:
      if content.containsDoubleLayoutPassSubviews() {
        resolved = .intrinsicHeightProposedOrIntrinsicWidth
      } else {
        let intrinsicSize = content.systemLayoutFittingIntrinsicSize()
        let zero = CGFloat(0)
        switch (width: intrinsicSize.width, height: intrinsicSize.height) {
        case (width: ...zero, height: ...zero):
          resolved = .proposed
        case (width: ...zero, height: zero.nextUp...):
          resolved = .intrinsicHeightProposedWidth
        case (width: zero.nextUp..., height: ...zero):
          resolved = .intrinsicWidthProposedHeight
        default:
          resolved = .intrinsic(intrinsicSize)
        }
      }
    case .proposed:
      resolved = .proposed
    case .intrinsicHeightProposedWidth:
      resolved = .intrinsicHeightProposedWidth
    case .intrinsicWidthProposedHeight:
      resolved = .intrinsicWidthProposedHeight
    case .intrinsicHeightProposedOrIntrinsicWidth:
      resolved = .intrinsicHeightProposedOrIntrinsicWidth
    case .intrinsic:
      resolved = .intrinsic(content.systemLayoutFittingIntrinsicSize())
    }
    _resolvedStrategy = resolved
    return resolved
  }

  private func setUpConstraints() {
    content.translatesAutoresizingMaskIntoConstraints = false

    let oldConstraints = [
      leadingConstraint,
      topConstraint,
      maxWidthConstraint,
      fixedWidthConstraint,
      fixedHeightConstraint,
    ]
    .compactMap { $0 }
    NSLayoutConstraint.deactivate(oldConstraints)

    leadingConstraint = content.leadingAnchor.constraint(equalTo: leadingAnchor)
    topConstraint = content.topAnchor.constraint(equalTo: topAnchor)
    maxWidthConstraint = content.widthAnchor.constraint(
      lessThanOrEqualToConstant: .maxConstraintValue)
    fixedWidthConstraint = content.widthAnchor.constraint(equalToConstant: 0)
    fixedHeightConstraint = content.heightAnchor.constraint(equalToConstant: 0)

    NSLayoutConstraint.activate([leadingConstraint, topConstraint].compactMap { $0 })
  }

  private func updateSizeConstraints() {
    // deactivate all size constraints to avoid side effects when doing a sizing pass to resolve the
    // measurement strategy
    let constraints = [
      maxWidthConstraint,
      fixedWidthConstraint,
      fixedHeightConstraint,
    ].compactMap { $0 }
    NSLayoutConstraint.deactivate(constraints)

    // avoid creating negative value constraints
    let nonNegativeProposedSize = CGSize(
      width: max(proposedSize.width, 0),
      height: max(proposedSize.height, 0))

    if let measuredSize = _measuredFittingSize {
      fixedWidthConstraint?.constant = measuredSize.width
      fixedHeightConstraint?.constant = measuredSize.height
      fixedWidthConstraint?.isActive = true
      fixedHeightConstraint?.isActive = true
    } else {
      switch resolvedStrategy {
      case .proposed:
        fixedWidthConstraint?.constant = nonNegativeProposedSize.width
        fixedHeightConstraint?.constant = nonNegativeProposedSize.height
        fixedWidthConstraint?.isActive = true
        fixedHeightConstraint?.isActive = true

      case .intrinsicHeightProposedWidth:
        fixedWidthConstraint?.constant = nonNegativeProposedSize.width
        fixedWidthConstraint?.isActive = true

      case .intrinsicWidthProposedHeight:
        fixedHeightConstraint?.constant = nonNegativeProposedSize.height
        fixedHeightConstraint?.isActive = true

      case .intrinsicHeightProposedOrIntrinsicWidth:
        maxWidthConstraint?.constant = nonNegativeProposedSize.width
        maxWidthConstraint?.isActive = nonNegativeProposedSize.width > 0

      case .intrinsic:
        break // no op, all size constraints already deactivated
      }
    }
  }

  private func setNeedsUpdateConstraintsForPlatform() {
    #if os(iOS) || os(tvOS)
    setNeedsUpdateConstraints()
    #elseif os(macOS)
    needsUpdateConstraints = true
    #endif
  }

  private func updateConstraintsForPlatformIfNeeded() {
    #if os(iOS) || os(tvOS)
    updateConstraintsIfNeeded()
    #elseif os(macOS)
    updateConstraintsForSubtreeIfNeeded()
    #endif
  }

  /// Measures the `uiView`, storing the resulting size in `measuredIntrinsicContentSize`.
  private func measureView() -> CGSize {
    updateConstraintsForPlatformIfNeeded()
    latestMeasurementBoundsSize = bounds.size

    var measuredSize: CGSize
    let proposedSizeElseBounds = proposedSize.replacingNoIntrinsicMetric(with: bounds.size)

    switch resolvedStrategy {
    case .proposed:
      measuredSize = .noIntrinsicMetric

    case .intrinsicHeightProposedWidth:
      measuredSize = content.systemLayoutFittingIntrinsicHeightFixedWidth(proposedSizeElseBounds.width)
      measuredSize.width = ViewType.noIntrinsicMetric

    case .intrinsicWidthProposedHeight:
      measuredSize = content.systemLayoutFittingIntrinsicWidthFixedHeight(proposedSizeElseBounds.height)
      measuredSize.height = ViewType.noIntrinsicMetric

    case .intrinsicHeightProposedOrIntrinsicWidth:
      let fittingSize = content.systemLayoutFittingIntrinsicSize()
      measuredSize = CGSize(
        width: min(fittingSize.width, proposedSize.width > 0 ? proposedSize.width : fittingSize.width),
        height: fittingSize.height)

    case .intrinsic(let size):
      measuredSize = size
    }

    _intrinsicContentSize = measuredSize

    let measuredFittingSize = measuredSize.replacingNoIntrinsicMetric(with: proposedSizeElseBounds)
    _measuredFittingSize = measuredFittingSize
    return measuredFittingSize
  }
}

// MARK: - SwiftUIMeasurementContainerStrategy

/// The measurement strategy of a `SwiftUIMeasurementContainer`.
public enum SwiftUIMeasurementContainerStrategy {
  /// The container makes a best effort to correctly choose the measurement strategy of the view.
  ///
  /// The best effort is based on a number of heuristics:
  /// - The `uiView` will be given its intrinsic width and/or height when measurement in that
  ///   dimension produces a positive value, while zero/negative values will result in that
  ///   dimension receiving the available space proposed by the parent.
  /// - If the view contains `UILabel` subviews that require a double layout pass as determined by support multiple lines of text
  ///   the view will default to `intrinsicHeightProposedOrIntrinsicWidth` to allow the labels to wrap.
  ///
  /// If you would like to opt out of automatic sizing for performance or to override the default
  /// behavior, choose another strategy.
  case automatic

  /// The `uiView` is sized to fill the area proposed by its parent.
  ///
  /// Typically used for views that should expand greedily in both axes, e.g. a background view.
  case proposed

  /// The `uiView`'s receives either its intrinsic width or the proposed width, whichever is smaller. The view receives its height based
  /// on the chosen width.
  ///
  /// Typically used for views that have a height that's a function of their width, e.g. a row with
  /// text that can wrap to multiple lines.
  case intrinsicHeightProposedOrIntrinsicWidth

  /// The `uiView` is sized with its intrinsic height and expands horizontally to fill the width
  /// proposed by its parent.
  ///
  /// Typically used for views that have a height that's a function of their parent's width.
  case intrinsicHeightProposedWidth

  /// The `uiView` is sized with its intrinsic width and expands vertically to fill the height
  /// proposed by its parent.
  ///
  /// Typically used for views that are free to grow vertically but have a fixed width, e.g. a view
  /// in a horizontal carousel.
  case intrinsicWidthProposedHeight

  /// The `uiView` is sized to its intrinsic width and height.
  ///
  /// Typically used for components with a specific intrinsic size in both axes, e.g. controls or
  /// inputs.
  case intrinsic
}

// MARK: - ResolvedSwiftUIMeasurementContainerStrategy

/// The resolved measurement strategy of a `SwiftUIMeasurementContainer`, matching the cases of the
/// `SwiftUIMeasurementContainerStrategy` without the automatic case.
private enum ResolvedSwiftUIMeasurementContainerStrategy {
  case proposed, intrinsicHeightProposedWidth, intrinsicWidthProposedHeight,
       intrinsicHeightProposedOrIntrinsicWidth, intrinsic(CGSize)
}

// MARK: - UILayoutPriority

extension LayoutPriorityType {
  /// An "almost required" constraint, useful for creating near-required constraints that don't
  /// error when unable to be satisfied.
  @nonobjc
  fileprivate static var almostRequired: LayoutPriorityType { .init(rawValue: required.rawValue - 1) }
}

// MARK: - UIView

extension ViewType {
  /// The `systemLayoutSizeFitting(…)` of this view with a compressed size and fitting priorities.
  @nonobjc
  fileprivate func systemLayoutFittingIntrinsicSize() -> CGSize {
    #if os(macOS)
    intrinsicContentSize
    #else
    systemLayoutSizeFitting(
      UIView.layoutFittingCompressedSize,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel)
    #endif
  }

  /// The `systemLayoutSizeFitting(…)` of this view with a compressed height with a fitting size
  /// priority and with the given fixed width and fitting priority.
  @nonobjc
  fileprivate func systemLayoutFittingIntrinsicHeightFixedWidth(
    _ width: CGFloat,
    priority: LayoutPriorityType = .almostRequired)
    -> CGSize
  {
    #if os(macOS)
    return CGSize(width: width, height: intrinsicContentSize.height)
    #else
    let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

    return systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: priority,
      verticalFittingPriority: .fittingSizeLevel)
    #endif
  }

  /// The `systemLayoutSizeFitting(…)` of this view with a compressed width with a fitting size
  /// priority and with the given fixed height and fitting priority.
  @nonobjc
  fileprivate func systemLayoutFittingIntrinsicWidthFixedHeight(
    _ height: CGFloat,
    priority: LayoutPriorityType = .almostRequired)
    -> CGSize
  {
    #if os(macOS)
    return CGSize(width: intrinsicContentSize.width, height: height)
    #else
    let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: height)

    return systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: priority)
    #endif
  }

  /// Whether this view or any of its subviews has a subview that has a double layout pass `UILabel` as determined by being
  /// configured to show multiple lines of text. This view should get a `intrinsicHeightProposedOrIntrinsicWidth` sizing
  /// strategy so that it wraps correctly.
  @nonobjc
  fileprivate func containsDoubleLayoutPassSubviews() -> Bool {
    #if os(macOS)
    return false
    #else
    var contains = false
    if let label = self as? UILabel, label.numberOfLines != 1 {
      contains = true
    }
    for subview in subviews {
      contains = contains || subview.containsDoubleLayoutPassSubviews()
    }
    return contains
    #endif
  }
}

// MARK: - CGSize

extension CGSize {
  /// A `CGSize` with `noIntrinsicMetric` for both its width and height.
  fileprivate static var noIntrinsicMetric: CGSize {
    .init(width: ViewType.noIntrinsicMetric, height: ViewType.noIntrinsicMetric)
  }

  /// Returns a `CGSize` with its width and/or height replaced with the corresponding field of the
  /// provided `fallback` size if they are `UIView.noIntrinsicMetric`.
  fileprivate func replacingNoIntrinsicMetric(with fallback: CGSize) -> CGSize {
    .init(
      width: width == ViewType.noIntrinsicMetric ? fallback.width : width,
      height: height == ViewType.noIntrinsicMetric ? fallback.height : height)
  }
}
