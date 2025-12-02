// Created by Andy Bartholomew on 12/2/24.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import Foundation

// MARK: - LottieURLSession

/// A protocol that abstracts URL session functionality for loading Lottie animations.
public protocol LottieURLSession: Sendable {
  /// Creates a data task that retrieves the contents of the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL to retrieve.
  ///   - completionHandler: The completion handler to call when the load request is complete.
  /// - Returns: A `LottieDataTask` that can be resumed or cancelled.
  func dataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
    -> LottieDataTask
}

// MARK: - LottieDataTask

/// A protocol that abstracts a URL session data task.
public protocol LottieDataTask: Sendable {
  /// Resumes the task, if it is suspended.
  func resume()

  /// Cancels the task.
  func cancel()
}

// MARK: - URLSession + LottieURLSession

extension URLSession: LottieURLSession {
  public func dataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
    -> LottieDataTask
  {
    dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask
  }
}

// MARK: - URLSessionDataTask + LottieDataTask

extension URLSessionDataTask: LottieDataTask { }
