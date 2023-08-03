// Created by Cal Stephens on 8/3/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Foundation

// MARK: - LottiePlaybackMode

/// Configuration for how a Lottie animation should be played
public enum LottiePlaybackMode: Hashable {
  /// The animation is paused at the given progress value,
  /// a value between 0.0 (0% progress) and 1.0 (100% progress).
  case progress(_ progress: AnimationProgressTime)

  /// The animation is paused at the given frame of the animation.
  case frame(_ frame: AnimationFrameTime)

  /// The animation is paused at the given time value from the start of the animation.
  case time(_ time: TimeInterval)

  /// Any existing animation will be paused at the current frame.
  case pause

  /// Plays the animation from a progress (0-1) to a progress (0-1).
  /// - Parameter fromProgress: The start progress of the animation. If `nil` the animation will start at the current progress.
  /// - Parameter toProgress: The end progress of the animation.
  /// - Parameter loopMode: The loop behavior of the animation.
  case fromProgress(_ fromProgress: AnimationProgressTime?, toProgress: AnimationProgressTime, loopMode: LottieLoopMode)

  /// The animation plays from the given `fromFrame` to the given `toFrame`.
  /// - Parameter fromFrame: The start frame of the animation. If `nil` the animation will start at the current frame.
  /// - Parameter toFrame: The end frame of the animation.
  /// - Parameter loopMode: The loop behavior of the animation.
  case fromFrame(_ fromFrame: AnimationFrameTime?, toFrame: AnimationFrameTime, loopMode: LottieLoopMode)

  /// Plays the animation from a named marker to another marker.
  ///
  /// Markers are point in time that are encoded into the Animation data and assigned a name.
  ///
  /// NOTE: If markers are not found the play command will exit.
  ///
  /// - Parameter fromMarker: The start marker for the animation playback. If `nil` the
  /// animation will start at the current progress.
  /// - Parameter toMarker: The end marker for the animation playback.
  /// - Parameter playEndMarkerFrame: A flag to determine whether or not to play the frame of the end marker. If the
  /// end marker represents the end of the section to play, it should be to true. If the provided end marker
  /// represents the beginning of the next section, it should be false.
  /// - Parameter loopMode: The loop behavior of the animation.
  case fromMarker(
    _ fromMarker: String?,
    toMarker: String,
    playEndMarkerFrame: Bool = true,
    loopMode: LottieLoopMode)

  /// Plays the animation from a named marker to the end of the marker's duration.
  ///
  /// A marker is a point in time with an associated duration that is encoded into the
  /// animation data and assigned a name.
  ///
  /// NOTE: If marker is not found the play command will exit.
  ///
  /// - Parameter marker: The start marker for the animation playback.
  /// - Parameter loopMode: The loop behavior of the animation.
  case marker(_ marker: String, loopMode: LottieLoopMode)

  /// Plays the given markers sequentially in order.
  ///
  /// A marker is a point in time with an associated duration that is encoded into the
  /// animation data and assigned a name. Multiple markers can be played sequentially
  /// to create programmable animations.
  ///
  /// If a marker is not found, it will be skipped.
  ///
  /// If a marker doesn't have a duration value, it will play with a duration of 0
  /// (effectively being skipped).
  ///
  /// If another animation is played (by calling any `play` method) while this
  /// marker sequence is playing, the marker sequence will be cancelled.
  ///
  /// - Parameter markers: The list of markers to play sequentially.
  case markers(_ markers: [String])
}

extension LottiePlaybackMode {
  /// Plays the animation from the current progress to a progress value (0-1).
  /// - Parameter toProgress: The end progress of the animation.
  /// - Parameter loopMode: The loop behavior of the animation.
  public static func toProgress(_ toProgress: AnimationProgressTime, loopMode: LottieLoopMode) -> LottiePlaybackMode {
    .fromProgress(nil, toProgress: toProgress, loopMode: loopMode)
  }

  // Plays the animation from the current frame to the given frame.
  /// - Parameter toFrame: The end frame of the animation.
  /// - Parameter loopMode: The loop behavior of the animation.
  public static func toFrame(_ toFrame: AnimationFrameTime, loopMode: LottieLoopMode) -> LottiePlaybackMode {
    .fromFrame(nil, toFrame: toFrame, loopMode: loopMode)
  }

  /// Plays the animation from the current frame to some marker.
  ///
  /// Markers are point in time that are encoded into the Animation data and assigned a name.
  ///
  /// NOTE: If the marker isn't found the play command will exit.
  ///
  /// - Parameter toMarker: The end marker for the animation playback.
  /// - Parameter playEndMarkerFrame: A flag to determine whether or not to play the frame of the end marker. If the
  /// end marker represents the end of the section to play, it should be to true. If the provided end marker
  /// represents the beginning of the next section, it should be false.
  /// - Parameter loopMode: The loop behavior of the animation.
  public static func toMarker(
    _ toMarker: String,
    playEndMarkerFrame: Bool = true,
    loopMode: LottieLoopMode)
    -> LottiePlaybackMode
  {
    .fromMarker(nil, toMarker: toMarker, playEndMarkerFrame: playEndMarkerFrame, loopMode: loopMode)
  }
}
