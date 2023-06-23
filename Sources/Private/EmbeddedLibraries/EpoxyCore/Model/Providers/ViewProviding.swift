// Created by eric_horacek on 12/16/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

/// The capability of providing an `View` instance
///
/// Typically conformed to by the `CallbackContext` of a `CallbackContextEpoxyModeled`.
public protocol ViewProviding {
  /// The `UIView` view of this type.
  associatedtype View: UIView

  /// The `UIView` view instance provided by this type.
  var view: View { get }
}
