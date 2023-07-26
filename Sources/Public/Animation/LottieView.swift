// Created by Bryn Bodayle on 1/20/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Combine
import SwiftUI

// MARK: - LottieView

/// A wrapper which exposes Lottie's `LottieAnimationView` to SwiftUI
@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
public struct LottieView<Placeholder: View>: UIViewConfiguringSwiftUIView {

  // MARK: Lifecycle

  /// Creates a `LottieView` that displays the given animation
  public init(animation: LottieAnimation?) where Placeholder == EmptyView {
    _animationSource = State(initialValue: animation.map(LottieAnimationSource.lottieAnimation))
    placeholder = nil
  }

  public init(dotLottieFile: DotLottieFile?) where Placeholder == EmptyView {
    _animationSource = State(initialValue: dotLottieFile.map(LottieAnimationSource.dotLottieAnimation))
    placeholder = nil
  }

  public init(_ lottieAnimationProvider: @escaping () async throws -> LottieAnimation?) where Placeholder == EmptyView {
    self.init(lottieAnimationProvider, placeholder: EmptyView.init)
  }

  public init(
    _ lottieAnimationProvider: @escaping () async throws -> LottieAnimation?,
    @ViewBuilder placeholder: @escaping (() -> Placeholder))
  {
    self.init(animationProvider: {
      let animation = try await lottieAnimationProvider()
      return animation.map(LottieAnimationSource.lottieAnimation)
    }, placeholder: placeholder)
  }

  public init(_ dotLottieAnimationProvider: @escaping () async throws -> DotLottieFile?) where Placeholder == EmptyView {
    self.init(
      dotLottieAnimationProvider,
      placeholder: EmptyView.init)
  }

  public init(
    _ dotLottieAnimationProvider: @escaping () async throws -> DotLottieFile?,
    @ViewBuilder placeholder: @escaping (() -> Placeholder))
  {
    self.init(
      animationProvider: {
        let animation = try await dotLottieAnimationProvider()
        return animation.map(LottieAnimationSource.dotLottieAnimation)
      },
      placeholder: placeholder)
  }

  fileprivate init(
    animationProvider: @escaping () async throws -> LottieAnimationSource?,
    @ViewBuilder placeholder: @escaping () -> Placeholder)
  {
    self.animationProvider = animationProvider
    self.placeholder = placeholder
    _animationSource = State(initialValue: nil)
  }

  // MARK: Public

  public var body: some View {
    ZStack {
      switch animationSource {
      case .lottieAnimation(let animation):
        LottieAnimationView.swiftUIView {
          LottieAnimationView(
            animation: animation,
            imageProvider: imageProvider,
            textProvider: textProvider,
            fontProvider: fontProvider,
            configuration: configuration)
        }
        .sizing(sizing)
        .configure { context in
          // We check referential equality of the animation before updating as updating the
          // animation has a side-effect of rebuilding the animation layer, and it would be
          // prohibitive to do so on every state update.
          if animation !== context.view.animation {
            context.view.animation = animation
          }
        }
        .configurations(configurations)
      case .dotLottieAnimation(let dotLottieFile):
        LottieAnimationView.swiftUIView {
          LottieAnimationView(
            dotLottie: dotLottieFile,
            textProvider: textProvider,
            fontProvider: fontProvider,
            configuration: configuration)
        }
        .sizing(sizing)
        .configurations(configurations)
      case .none:
        if let placeholder {
          placeholder()
        }
      }
    }
    .loadAnimation(
      animationProvider: animationProvider,
      animation: $animationSource)
  }

  /// Returns a copy of this `LottieView` updated to have the given closure applied to its
  /// represented `LottieAnimationView` whenever it is updated via the `updateUIView(…)`
  /// or `updateNSView(…)` method.
  public func configure(_ configure: @escaping (LottieAnimationView) -> Void) -> Self {
    var copy = self
    copy.configurations.append { context in
      configure(context.view)
    }
    return copy
  }

  /// Returns a copy of this view that can be resized by scaling its animation to fit the size
  /// offered by its parent.
  public func resizable() -> Self {
    var copy = self
    copy.sizing = .proposed
    return copy
  }

  /// Returns a copy of this view that loops its animation whenever visible by playing
  /// whenever it is updated with a `loopMode` of `.loop` if not already playing.
  public func looping() -> Self {
    configure { view in
      if !view.isAnimationPlaying {
        view.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
      }
    }
  }

  /// Returns a copy of this view updated to have the provided background behavior.
  public func backgroundBehavior(_ value: LottieBackgroundBehavior) -> Self {
    configure { view in
      view.backgroundBehavior = value
    }
  }

  /// Returns a copy of this view with its accessibility label updated to the given value.
  public func accessibilityLabel(_ accessibilityLabel: String?) -> Self {
    configure { view in
      #if os(macOS)
      view.setAccessibilityElement(accessibilityLabel != nil)
      view.setAccessibilityLabel(accessibilityLabel)
      #else
      view.isAccessibilityElement = accessibilityLabel != nil
      view.accessibilityLabel = accessibilityLabel
      #endif
    }
  }

  /// Returns a copt of this view with its `LottieConfiguration` updated to the given value.
  public func configuration(_ configuration: LottieConfiguration) -> Self {
    var copy = self
    copy.configuration = configuration

    copy = copy.configure { view in
      if view.configuration != configuration {
        view.configuration = configuration
      }
    }

    return copy
  }

  /// Returns a copy of this view with its image provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func imageProvider<ImageProvider: AnimationImageProvider & Equatable>(_ imageProvider: ImageProvider) -> Self {
    var copy = self
    copy.imageProvider = imageProvider

    copy = copy.configure { view in
      if (view.imageProvider as? ImageProvider) != imageProvider {
        view.imageProvider = imageProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view with its text provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func textProvider<TextProvider: AnimationTextProvider & Equatable>(_ textProvider: TextProvider) -> Self {
    var copy = self
    copy.textProvider = textProvider

    copy = copy.configure { view in
      if (view.textProvider as? TextProvider) != textProvider {
        view.textProvider = textProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view with its image provider updated to the given value.
  /// The image provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func fontProvider<FontProvider: AnimationFontProvider & Equatable>(_ fontProvider: FontProvider) -> Self {
    var copy = self
    copy.fontProvider = fontProvider

    copy = configure { view in
      if (view.fontProvider as? FontProvider) != fontProvider {
        view.fontProvider = fontProvider
      }
    }

    return copy
  }

  /// Returns a copy of this view using the given value provider for the given keypath.
  /// The value provider must be `Equatable` to avoid unnecessary state updates / re-renders.
  public func valueProvider<ValueProvider: AnyValueProvider & Equatable>(
    _ valueProvider: ValueProvider,
    for keypath: AnimationKeypath)
    -> Self
  {
    configure { view in
      if (view.valueProviders[keypath] as? ValueProvider) != valueProvider {
        view.setValueProvider(valueProvider, keypath: keypath)
      }
    }
  }

  /// Returns a copy of this view updated to display the given `AnimationProgressTime`.
  ///  - If the `currentProgress` value is provided, the `currentProgress` of the
  ///    underlying `LottieAnimationView` is updated. This will pause any existing animations.
  ///  - If the `animationProgress` is `nil`, no changes will be made and any existing animations
  ///    will continue playing uninterrupted.
  public func currentProgress(_ currentProgress: AnimationProgressTime?) -> Self {
    configure { view in
      if
        let currentProgress = currentProgress,
        view.currentProgress != currentProgress
      {
        view.currentProgress = currentProgress
      }
    }
  }

  /// Returns a copy of this view updated to display the given `AnimationFrameTime`.
  ///  - If the `currentFrame` value is provided, the `currentFrame` of the
  ///    underlying `LottieAnimationView` is updated. This will pause any existing animations.
  ///  - If the `currentFrame` is `nil`, no changes will be made and any existing animations
  ///    will continue playing uninterrupted.
  public func currentFrame(_ currentFrame: AnimationFrameTime?) -> Self {
    configure { view in
      if
        let currentFrame = currentFrame,
        view.currentFrame != currentFrame
      {
        view.currentFrame = currentFrame
      }
    }
  }

  /// Returns a copy of this view updated to display the given time value.
  ///  - If the `currentTime` value is provided, the `currentTime` of the
  ///    underlying `LottieAnimationView` is updated. This will pause any existing animations.
  ///  - If the `currentTime` is `nil`, no changes will be made and any existing animations
  ///    will continue playing uninterrupted.
  public func currentTime(_ currentTime: TimeInterval?) -> Self {
    configure { view in
      if
        let currentTime = currentTime,
        view.currentTime != currentTime
      {
        view.currentTime = currentTime
      }
    }
  }

  /// Returns a view that updates the given binding each frame with the animation's `realtimeAnimationProgress`.
  /// The `LottieView` is wrapped in a `TimelineView` with the `.animation` schedule.
  ///  - This is a one-way binding. Its value is updated but never read.
  ///  - If provided, the binding will be updated each frame with the `realtimeAnimationProgress`
  ///    of the underlying `LottieAnimationView`. This is potentially expensive since it triggers
  ///    a state update every frame.
  ///  - If the binding is `nil`, the `TimelineView` will be paused and no updates will occur to the binding.
  @available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
  public func getRealtimeAnimationProgress(_ realtimeAnimationProgress: Binding<AnimationProgressTime>?) -> some View {
    TimelineView(.animation(paused: realtimeAnimationProgress == nil)) { _ in
      configure { view in
        if let realtimeAnimationProgress = realtimeAnimationProgress {
          DispatchQueue.main.async {
            realtimeAnimationProgress.wrappedValue = view.realtimeAnimationProgress
          }
        }
      }
    }
  }

  /// Returns a view that updates the given binding each frame with the animation's `realtimeAnimationProgress`.
  /// The `LottieView` is wrapped in a `TimelineView` with the `.animation` schedule.
  ///  - This is a one-way binding. Its value is updated but never read.
  ///  - If provided, the binding will be updated each frame with the `realtimeAnimationProgress`
  ///    of the underlying `LottieAnimationView`. This is potentially expensive since it triggers
  ///    a state update every frame.
  ///  - If the binding is `nil`, the `TimelineView` will be paused and no updates will occur to the binding.
  @available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
  public func getRealtimeAnimationFrame(_ realtimeAnimationFrame: Binding<AnimationProgressTime>?) -> some View {
    TimelineView(.animation(paused: realtimeAnimationFrame == nil)) { _ in
      configure { view in
        if let realtimeAnimationFrame = realtimeAnimationFrame {
          DispatchQueue.main.async {
            realtimeAnimationFrame.wrappedValue = view.realtimeAnimationFrame
          }
        }
      }
    }
  }

  // MARK: Internal

  var configurations = [SwiftUIView<LottieAnimationView, Void>.Configuration]()

  // MARK: Private

  @State private var animationSource: LottieAnimationSource?
  private var imageProvider: AnimationImageProvider?
  private var textProvider: AnimationTextProvider = DefaultTextProvider()
  private var fontProvider: AnimationFontProvider = DefaultFontProvider()
  private var configuration: LottieConfiguration = .shared
  private var sizing = SwiftUIMeasurementContainerStrategy.automatic
  private var animationProvider: (() async throws -> LottieAnimationSource?)?
  private let placeholder: (() -> Placeholder)?

}

// MARK: - LottieAnimationSource

private enum LottieAnimationSource {
  case lottieAnimation(LottieAnimation)
  case dotLottieAnimation(DotLottieFile)
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
extension View {
  fileprivate func loadAnimation(
    animationProvider: (() async throws -> LottieAnimationSource?)?,
    animation: Binding<LottieAnimationSource?>)
    -> some View
  {
    onAppear {
      Task {
        if let animationLoaded = try? await animationProvider?() {
          animation.wrappedValue = animationLoaded
        }
      }
    }
  }
}
