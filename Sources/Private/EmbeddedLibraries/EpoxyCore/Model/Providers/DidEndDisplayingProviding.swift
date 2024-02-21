// Created by eric_horacek on 12/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - DidEndDisplayingProviding

/// A sentinel protocol for enabling an `CallbackContextEpoxyModeled` to provide a
/// `didEndDisplaying` closure property.
public protocol DidEndDisplayingProviding { }

// MARK: - CallbackContextEpoxyModeled

extension CallbackContextEpoxyModeled where Self: DidEndDisplayingProviding {

  // MARK: Public

  /// A closure that's called when a view is no longer displayed following any disappearance
  /// animations and when it has been removed from the view hierarchy.
  public typealias DidEndDisplaying = (_ context: CallbackContext) -> Void

  /// A closure that's called when the view is no longer displayed following any disappearance
  /// animations and when it has been removed from the view hierarchy.
  public var didEndDisplaying: DidEndDisplaying? {
    get { self[didEndDisplayingProperty] }
    set { self[didEndDisplayingProperty] = newValue }
  }

  /// Returns a copy of this model with the given did end displaying closure called after the
  /// current did end displaying closure of this model, if there is one.
  public func didEndDisplaying(_ value: DidEndDisplaying?) -> Self {
    copy(updating: didEndDisplayingProperty, to: value)
  }

  // MARK: Private

  private var didEndDisplayingProperty: EpoxyModelProperty<DidEndDisplaying?> {
    .init(
      keyPath: \Self.didEndDisplaying,
      defaultValue: nil,
      updateStrategy: .chain())
  }
}
