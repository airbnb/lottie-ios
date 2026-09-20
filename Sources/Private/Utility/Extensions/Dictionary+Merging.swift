
extension Dictionary {
  static func merging(
    _ dictionaries: Self...,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    try dictionaries.reduce(into: [:]) { result, dict in
      try result.merge(dict, uniquingKeysWith: combine)
    }
  }
}
