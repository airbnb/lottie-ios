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
  /// - Returns: A `URLSessionDataTask` that can be resumed or cancelled, or `nil` for mock implementations.
  func lottieDataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
  ) -> URLSessionDataTask?
}

// MARK: - URLSession + LottieURLSession

extension URLSession: LottieURLSession {
  public func lottieDataTask(
    with url: URL,
    completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
  ) -> URLSessionDataTask? {
    dataTask(with: url, completionHandler: completionHandler)
  }
}
