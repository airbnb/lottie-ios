// Created by Cal Stephens on 8/14/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

// MARK: - Vector1DEffectValue

final class Vector1DEffectValue: EffectValue {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    value = try? container.decode(KeyframeGroup<LottieVector1D>.self, forKey: .value)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let valueDictionary: [String: Any] = try dictionary.value(for: CodingKeys.value)
    value = try KeyframeGroup<LottieVector1D>(dictionary: valueDictionary)
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// The value of the slider
  let value: KeyframeGroup<LottieVector1D>?

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(value, forKey: .value)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case value = "v"
  }
}

// MARK: @unchecked Sendable

/// `Vector1DEffectValue` inherits `@unchecked Sendable` from `EffectValue` and
/// we need to restate that here to avoid a warning in Xcode 16
// swiftlint:disable:next no_unchecked_sendable
extension Vector1DEffectValue: @unchecked Sendable { }
