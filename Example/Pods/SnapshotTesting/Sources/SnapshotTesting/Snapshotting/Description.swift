extension Snapshotting where Format == String {
  /// A snapshot strategy that captures a value's textual description from `String`'s `init(description:)`
  /// initializer.
  public static var description: Snapshotting {
    return SimplySnapshotting.lines.pullback(String.init(describing:))
  }
}
