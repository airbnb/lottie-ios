// Created by Claude on behalf of Airbnb Inc.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Foundation

// MARK: - LottieURLSession

/// A protocol that abstracts URL session functionality for loading Lottie animations.
///
/// This protocol allows you to inject a custom URL session implementation,
/// which is particularly useful for:
/// - Disabling network requests during screenshot tests for more stable results
/// - Mocking network responses in unit tests
/// - Implementing custom caching or request modification logic
///
/// By default, Lottie uses `URLSession.shared` for network requests.
/// To disable network requests (e.g., for screenshot tests), you can create
/// a mock implementation that ignores requests:
///
/// ```swift
/// class DisabledURLSession: LottieURLSession {
///   func lottieDataTask(
///     with url: URL,
///     completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
///     -> LottieDataTask
///   {
///     // Return a no-op task that never makes a network request
///     completionHandler(nil, nil, URLError(.cancelled))
///     return DisabledDataTask()
///   }
/// }
///
/// class DisabledDataTask: LottieDataTask {
///   func resume() { }
///   func cancel() { }
/// }
///
/// // In your test setup:
/// LottieConfiguration.shared.defaultURLSession = DisabledURLSession()
/// ```
public protocol LottieURLSession: Sendable {
  /// Creates a data task that retrieves the contents of the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL to retrieve.
  ///   - completionHandler: The completion handler to call when the load request is complete.
  /// - Returns: A `LottieDataTask` that can be resumed or cancelled.
  func lottieDataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
    -> LottieDataTask
}

// MARK: - LottieDataTask

/// A protocol that abstracts a URL session data task for Lottie animations.
///
/// This protocol provides the minimal interface needed to control a data task:
/// resuming it to start the request, or cancelling it to abort.
public protocol LottieDataTask: Sendable {
  /// Resumes the task, if it is suspended.
  func resume()

  /// Cancels the task.
  func cancel()
}

// MARK: - URLSession + LottieURLSession

extension URLSession: LottieURLSession {
  public func lottieDataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
    -> LottieDataTask
  {
    dataTask(with: url, completionHandler: completionHandler)
  }
}

// MARK: - URLSessionDataTask + LottieDataTask

extension URLSessionDataTask: LottieDataTask { }
