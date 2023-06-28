// Created by Bryn Bodayle on 1/20/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

#if !os(macOS)

// MARK: - LottieView

/// A wrapper which exposes Lottie's `LottieAnimationView` to SwiftUI
@available(iOS 13.0, tvOS 13.0, *)
public struct LottieView: UIViewConfiguringSwiftUIView {

  // MARK: Lifecycle

  public init(
    animation: LottieAnimation,
    imageProvider: AnimationImageProvider? = nil,
    textProvider: AnimationTextProvider? = nil,
    fontProvider: AnimationFontProvider? = nil,
    configuration: LottieConfiguration = .shared,
    accessibilityLabel: String? = nil)
  {
    self.animation = animation
    self.imageProvider = imageProvider
    self.textProvider = textProvider
    self.fontProvider = fontProvider
    self.configuration = configuration
    self.accessibilityLabel = accessibilityLabel
  }

  // MARK: Public

  public var body: some View {
    LottieAnimationView.swiftUIView {
      LottieAnimationView(
        animation: animation,
        imageProvider: imageProvider,
        textProvider: textProvider ?? DefaultTextProvider(),
        fontProvider: fontProvider ?? DefaultFontProvider(),
        configuration: configuration)
    }
    .sizing(sizing)
    .configure { context in
      context.view.isAccessibilityElement = accessibilityLabel != nil
      context.view.accessibilityLabel = accessibilityLabel

      // We check referential equality of the animation before updating as updating the
      // animation has a side-effect of rebuilding the animation layer, and it would be
      // prohibitive to do so on every state update.
      if animation !== context.view.animation {
        context.view.animation = animation
      }

      // Technically the image provider, text provider, font provider, and Lottie configuration
      // could also need to be updated here, but there's no performant way to check their equality,
      // so we assume they are not.
    }
    .configurations(configurations)
  }

  /// Returns a copy of this view that can be resized by scaling its animation to fit the size
  /// offered by its parent.
  public func resizable() -> Self {
    var copy = self
    copy.sizing = .proposed
    return copy
  }

  /// Returns a copy of this animation view that loops its animation whenever visible by playing
  /// whenever it is updated with a `loopMode` of `.loop` if not already playing.
  public func looping() -> Self {
    configure { context in
      if !context.view.isAnimationPlaying {
        context.view.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
      }
    }
  }

  /// Returns a copy of this animation view with its `AnimationView` updated to have the provided
  /// background behavior.
  public func backgroundBehavior(_ value: LottieBackgroundBehavior) -> Self {
    configure { context in
      context.view.backgroundBehavior = value
    }
  }

  // MARK: Internal

  var configurations = [SwiftUIUIView<LottieAnimationView, Void>.Configuration]()

  // MARK: Private

  private let accessibilityLabel: String?
  private let animation: LottieAnimation?
  private let imageProvider: Lottie.AnimationImageProvider?
  private let textProvider: Lottie.AnimationTextProvider?
  private let fontProvider: Lottie.AnimationFontProvider?
  private let configuration: LottieConfiguration
  private var sizing = SwiftUIMeasurementContainerStrategy.automatic
}

#endif
