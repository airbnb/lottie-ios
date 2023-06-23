// Created by eric_horacek on 12/1/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - StyleIDProviding

public protocol StyleIDProviding {
  /// An optional ID for a style type to use for reuse of a view.
  ///
  /// Use this to differentiate between different styling configurations.
  var styleID: AnyHashable? { get }
}

// MARK: - EpoxyModeled

extension EpoxyModeled where Self: StyleIDProviding {

  // MARK: Public

  public var styleID: AnyHashable? {
    get { self[styleIDProperty] }
    set { self[styleIDProperty] = newValue }
  }

  /// Returns a copy of this model with the `styleID` replaced with the provided `value`.
  public func styleID(_ value: AnyHashable?) -> Self {
    copy(updating: styleIDProperty, to: value)
  }

  // MARK: Private

  private var styleIDProperty: EpoxyModelProperty<AnyHashable?> {
    .init(
      keyPath: \StyleIDProviding.styleID,
      defaultValue: nil,
      updateStrategy: .replace)
  }
}
