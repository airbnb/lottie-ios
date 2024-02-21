// Created by eric_horacek on 9/16/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Combine
import SwiftUI

#if !os(macOS)

// MARK: - SwiftUIHostingViewReuseBehavior

/// The reuse behavior of an `EpoxySwiftUIHostingView`.
public enum SwiftUIHostingViewReuseBehavior: Hashable {
  /// Instances of a `EpoxySwiftUIHostingView` with `RootView`s of same type can be reused within
  /// the Epoxy container.
  ///
  /// This is the default reuse behavior.
  case reusable
  /// Instances of a `EpoxySwiftUIHostingView` with `RootView`s of same type can only reused within
  /// the Epoxy container when they have identical `reuseID`s.
  case unique(reuseID: AnyHashable)
}

// MARK: - CallbackContextEpoxyModeled

extension CallbackContextEpoxyModeled
  where
  Self: WillDisplayProviding & DidEndDisplayingProviding,
  CallbackContext: ViewProviding & AnimatedProviding
{
  /// Updates the appearance state of a `EpoxySwiftUIHostingView` in coordination with the
  /// `willDisplay` and `didEndDisplaying` callbacks of this `EpoxyableModel`.
  ///
  /// - Note: You should only need to call then from the implementation of a concrete
  ///   `EpoxyableModel` convenience vendor method, e.g. `SwiftUI.View.itemModel(…)`.
  public func linkDisplayLifecycle<RootView: View>() -> Self
    where
    CallbackContext.View == EpoxySwiftUIHostingView<RootView>
  {
    willDisplay { context in
      context.view.handleWillDisplay(animated: context.animated)
    }
    .didEndDisplaying { context in
      context.view.handleDidEndDisplaying(animated: context.animated)
    }
  }
}

// MARK: - EpoxySwiftUIHostingView

/// A `UIView` that hosts a SwiftUI view within an Epoxy container, e.g. an Epoxy `CollectionView`.
///
/// Wraps an `EpoxySwiftUIHostingController` and adds it as a child view controller to the next
/// ancestor view controller in the hierarchy.
///
/// There's a private API that accomplishes this same behavior without needing a `UIViewController`:
/// `_UIHostingView`, but we can't safely use it as 1) the behavior may change out from under us, 2)
/// the API is private and 3) the `_UIHostingView` doesn't not accept setting a new `View` instance.
///
/// - SeeAlso: `EpoxySwiftUIHostingController`
public final class EpoxySwiftUIHostingView<RootView: View>: UIView, EpoxyableView {

  // MARK: Lifecycle

  public init(style: Style) {
    // Ignore the safe area to ensure the view isn't laid out incorrectly when being sized while
    // overlapping the safe area.
    epoxyContent = EpoxyHostingContent(rootView: style.initialContent.rootView)
    viewController = EpoxySwiftUIHostingController(
      rootView: .init(content: epoxyContent, environment: epoxyEnvironment),
      ignoreSafeArea: style.ignoreSafeArea)

    dataID = style.initialContent.dataID ?? DefaultDataID.noneProvided as AnyHashable

    super.init(frame: .zero)

    epoxyEnvironment.intrinsicContentSizeInvalidator = .init(invalidate: { [weak self] in
      self?.viewController.view.invalidateIntrinsicContentSize()

      // Inform the enclosing collection view that the size has changed, if we're contained in one,
      // allowing the cell to resize.
      //
      // On iOS 16+, we could call `invalidateIntrinsicContentSize()` on the enclosing collection
      // view cell instead, but that currently causes visual artifacts with `MagazineLayout`. The
      // better long term fix is likely to switch to `UIHostingConfiguration` on iOS 16+ anyways.
      if let enclosingCollectionView = self?.superview?.superview?.superview as? UICollectionView {
        enclosingCollectionView.collectionViewLayout.invalidateLayout()
      }
    })
    layoutMargins = .zero
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public struct Style: Hashable {

    // MARK: Lifecycle

    public init(
      reuseBehavior: SwiftUIHostingViewReuseBehavior,
      initialContent: Content,
      ignoreSafeArea: Bool = true)
    {
      self.reuseBehavior = reuseBehavior
      self.initialContent = initialContent
      self.ignoreSafeArea = ignoreSafeArea
    }

    // MARK: Public

    public var reuseBehavior: SwiftUIHostingViewReuseBehavior
    public var initialContent: Content
    public var ignoreSafeArea: Bool

    public static func == (lhs: Style, rhs: Style) -> Bool {
      lhs.reuseBehavior == rhs.reuseBehavior
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(reuseBehavior)
    }
  }

  public struct Content: Equatable {
    public init(rootView: RootView, dataID: AnyHashable?) {
      self.rootView = rootView
      self.dataID = dataID
    }

    public var rootView: RootView
    public var dataID: AnyHashable?

    public static func == (_: Content, _: Content) -> Bool {
      // The content should never be equal since we need the `rootView` to be updated on every
      // content change.
      false
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    // Having our window set is an indicator that we should try adding our `viewController` as a
    // child. We try this from a few other places to cover all of our bases.
    addViewControllerIfNeededAndReady()
  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()

    // Having our superview set is an indicator that we should try adding our `viewController` as a
    // child. We try this from a few other places to cover all of our bases.
    //
    // Previously, we did not implement this function, and instead relied on `didMoveToWindow` being
    // called to know when to attempt adding our `viewController` as a child. This resulted in a
    // cell sizing issue, where the cell would return an estimated size. This was due to a timing
    // issue with adding our `viewController` as a child. The order of events that caused the bug is
    // as follows:
    // 1. `collectionView(_:cellForItemAt:)` is called
    // 2. An `EpoxySwiftUIHostingView` is created via `makeView()`
    // 3. The hosting view is added as a subview of, and constrained to, the cell's `contentView`
    // via a call to `setViewIfNeeded(view:)`
    // 4. The hosting view's `didMoveToSuperview` function is called, but prior to this change, we
    //    did nothing in this function
    // 5. We return from `collectionView(_:cellForItemAt:)`
    // 6. `UICollectionView` calls the cell's `preferredLayoutAttributesFitting:` function, which
    //    returns an estimated size
    // 7. The hosting view's `didMoveToWindow` function is called, and we finally add our
    //    `viewController` as a child
    // 8. No additional sizing attempt is made by `UICollectionViewFlowLayout` or `MagazineLayout`
    //    (for some reason compositional layout recovers)
    //
    // A reliable repro case for this bug is the following setup:
    // 1. Have a tab bar controller with two tabs - the first containing an Epoxy collection view,
    //    the second containing nothing
    // 2. Have a reload function on the first view controller that sets one section with a few
    //    SwiftUI items (`Color.red.frame(width: 300, height: 300`).itemModel(dataID: ...)`)
    // 3. Switch away from the tab containing the collection view
    // 4. Call the reload function on the collection view on the tab that's no longer visible
    // 4. Upon returning to the first tab, the collection view will contain incorrectly sized cells
    addViewControllerIfNeededAndReady()
  }

  public func setContent(_ content: Content, animated _: Bool) {
    // This triggers a change in the observed `EpoxyHostingContent` object and allows the
    // propagation of the SwiftUI transaction, instead of just replacing the `rootView`.
    epoxyContent.rootView = content.rootView
    dataID = content.dataID ?? DefaultDataID.noneProvided as AnyHashable

    // The view controller must be added to the view controller hierarchy to measure its content.
    addViewControllerIfNeededAndReady()

    // We need to layout the view to ensure it gets resized properly when cells are re-used
    viewController.view.setNeedsLayout()
    viewController.view.layoutIfNeeded()

    // This is required to ensure that views with new content are properly resized.
    viewController.view.invalidateIntrinsicContentSize()
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()

    let margins = layoutMargins
    switch effectiveUserInterfaceLayoutDirection {
    case .rightToLeft:
      epoxyEnvironment.layoutMargins = .init(
        top: margins.top,
        leading: margins.right,
        bottom: margins.bottom,
        trailing: margins.left)
    case .leftToRight:
      fallthrough
    @unknown default:
      epoxyEnvironment.layoutMargins = .init(
        top: margins.top,
        leading: margins.left,
        bottom: margins.bottom,
        trailing: margins.right)
    }

    // Allow the layout margins update to fully propagate through to the SwiftUI View before
    // invalidating the layout.
    DispatchQueue.main.async {
      self.viewController.view.invalidateIntrinsicContentSize()
    }
  }

  public func handleWillDisplay(animated: Bool) {
    guard state != .appeared, window != nil else { return }
    transition(to: .appearing(animated: animated))
    transition(to: .appeared)
  }

  public func handleDidEndDisplaying(animated: Bool) {
    guard state != .disappeared else { return }
    transition(to: .disappearing(animated: animated))
    transition(to: .disappeared)
  }

  // MARK: Private

  private let viewController: EpoxySwiftUIHostingController<EpoxyHostingWrapper<RootView>>
  private let epoxyContent: EpoxyHostingContent<RootView>
  private let epoxyEnvironment = EpoxyHostingEnvironment()
  private var dataID: AnyHashable
  private var state: AppearanceState = .disappeared

  /// Updates the appearance state of the `viewController`.
  private func transition(to state: AppearanceState) {
    guard state != self.state else { return }

    // See "Handling View-Related Notifications" section for the state machine diagram.
    // https://developer.apple.com/documentation/uikit/uiviewcontroller
    switch (to: state, from: self.state) {
    case (to: .appearing(let animated), from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: animated)
      addViewControllerIfNeededAndReady()
    case (to: .disappearing(let animated), from: .appeared):
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .disappeared, from: .disappearing):
      removeViewControllerIfNeeded()
    case (to: .appeared, from: .appearing):
      viewController.endAppearanceTransition()
    case (to: .disappeared, from: .appeared):
      viewController.beginAppearanceTransition(false, animated: true)
      removeViewControllerIfNeeded()
    case (to: .appeared, from: .disappearing(let animated)):
      viewController.beginAppearanceTransition(true, animated: animated)
      viewController.endAppearanceTransition()
    case (to: .disappeared, from: .appearing(let animated)):
      viewController.beginAppearanceTransition(false, animated: animated)
      removeViewControllerIfNeeded()
    case (to: .appeared, from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: false)
      addViewControllerIfNeededAndReady()
      viewController.endAppearanceTransition()
    case (to: .appearing(let animated), from: .appeared):
      viewController.beginAppearanceTransition(false, animated: animated)
      viewController.beginAppearanceTransition(true, animated: animated)
    case (to: .appearing(let animated), from: .disappearing):
      viewController.beginAppearanceTransition(true, animated: animated)
    case (to: .disappearing(let animated), from: .disappeared):
      viewController.beginAppearanceTransition(true, animated: animated)
      addViewControllerIfNeededAndReady()
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .disappearing(let animated), from: .appearing):
      viewController.beginAppearanceTransition(false, animated: animated)
    case (to: .appearing, from: .appearing),
         (to: .appeared, from: .appeared),
         (to: .disappearing, from: .disappearing),
         (to: .disappeared, from: .disappeared):
      // This should never happen since we guard on identical states.
      EpoxyLogger.shared.assertionFailure("Impossible state change from \(self.state) to \(state)")
    }

    self.state = state
  }

  private func addViewControllerIfNeededAndReady() {
    guard let superview = superview else {
      // If our superview is nil, we're too early and have no chance of finding a view controller
      // up the responder chain.
      return
    }

    // This isn't great, and means that we're going to add this view controller as a child view
    // controller of a view controller somewhere else in the hierarchy, which the author of that
    // view controller may not be expecting. However there's not really a better pathway forward
    // here without requiring a view controller instance to be passed all the way through, which is
    // both burdensome and error-prone.
    let nextViewController = superview.next(UIViewController.self)

    if nextViewController == nil, window == nil {
      // If the view controller is nil, but our window is also nil, we're a bit too early. It's
      // possible to find a view controller up the responder chain without having a window, which is
      // why we don't guard or assert on having a window.
      return
    }

    guard let nextViewController = nextViewController else {
      // One of the two previous early returns should have prevented us from getting here.
      EpoxyLogger.shared.assertionFailure(
        """
        Unable to add a UIHostingController view, could not locate a UIViewController in the \
        responder chain for view with ID \(dataID) of type \(RootView.self).
        """)
      return
    }

    guard viewController.parent !== nextViewController else { return }

    // If in a different parent, we need to first remove from it before we add.
    if viewController.parent != nil {
      removeViewControllerIfNeeded()
    }

    addViewController(to: nextViewController)

    state = .appeared
  }

  private func addViewController(to parent: UIViewController) {
    viewController.willMove(toParent: parent)

    parent.addChild(viewController)

    addSubview(viewController.view)

    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      viewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      // Pining the hosting view controller to layoutMarginsGuide ensures the content respects the top safe area
      // when installed inside a `TopBarContainer`
      viewController.view.topAnchor.constraint(equalTo: topAnchor),
      viewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      // Pining the hosting view controller to layoutMarginsGuide ensures the content respects the bottom safe area
      // when installed inside a `BottomBarContainer`
      viewController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    viewController.didMove(toParent: parent)
  }

  private func removeViewControllerIfNeeded() {
    guard viewController.parent != nil else { return }

    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
    viewController.didMove(toParent: nil)
  }
}

// MARK: - AppearanceState

/// The appearance state of a `EpoxySwiftUIHostingController` contained within a
/// `EpoxySwiftUIHostingView`.
private enum AppearanceState: Equatable {
  case appearing(animated: Bool)
  case appeared
  case disappearing(animated: Bool)
  case disappeared
}

// MARK: - UIResponder

extension UIResponder {
  /// Recursively traverses the responder chain upwards from this responder to its next responder
  /// until the a responder of the given type is located, else returns `nil`.
  @nonobjc
  fileprivate func next<ResponderType>(_ type: ResponderType.Type) -> ResponderType? {
    self as? ResponderType ?? next?.next(type)
  }
}

// MARK: - EpoxyHostingContent

/// The object that is used to communicate changes in the root view to the
/// `EpoxySwiftUIHostingController`.
final class EpoxyHostingContent<RootView: View>: ObservableObject {

  // MARK: Lifecycle

  init(rootView: RootView) {
    _rootView = .init(wrappedValue: rootView)
  }

  // MARK: Internal

  @Published var rootView: RootView
}

// MARK: - EpoxyHostingEnvironment

/// The object that is used to communicate values to SwiftUI views within an
/// `EpoxySwiftUIHostingController`, e.g. layout margins.
final class EpoxyHostingEnvironment: ObservableObject {
  @Published var layoutMargins = EdgeInsets()
  @Published var intrinsicContentSizeInvalidator = EpoxyIntrinsicContentSizeInvalidator(invalidate: { })
}

// MARK: - EpoxyHostingWrapper

/// The wrapper view that is used to communicate values to SwiftUI views within an
/// `EpoxySwiftUIHostingController`, e.g. layout margins.
struct EpoxyHostingWrapper<Content: View>: View {
  @ObservedObject var content: EpoxyHostingContent<Content>
  @ObservedObject var environment: EpoxyHostingEnvironment

  var body: some View {
    content.rootView
      .environment(\.epoxyLayoutMargins, environment.layoutMargins)
      .environment(\.epoxyIntrinsicContentSizeInvalidator, environment.intrinsicContentSizeInvalidator)
  }
}

#endif
