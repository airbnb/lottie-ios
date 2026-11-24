import QuartzCore

private var animationThreadKey: UInt8 = 0

extension CALayer {
  /// Stores the Core Animation renderer's configured build thread at the type
  /// (class) level, rather than per-instance, so that any layer in a deeply
  /// nested Core Animation layer hierarchy can read this configuration without
  /// needing it threaded through every intermediate layer/initializer.
  ///
  /// This uses the Objective-C associated object API rather than a stored
  /// property because `CALayer` is extended (not subclassed), and Swift
  /// extensions cannot add stored properties. Associating the value with the
  /// class object itself (`self` here refers to the metatype) makes it a
  /// single, shared value for all instances of this class.
  ///
  /// This is only meaningful when read from within the Core Animation
  /// renderer's execution path, since that's the only context in which it's
  /// set.
  static var animationSetupThread: RenderingEngine.AnimationSetupThread? {
    get {
      objc_getAssociatedObject(self, &animationThreadKey) as? RenderingEngine.AnimationSetupThread
    }
    set {
      objc_setAssociatedObject(
        self,
        &animationThreadKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  /// Whether the Core Animation renderer is currently configured to create
  /// its animation on a background thread, as opposed to the main thread.
  static var isCreatingAnimationsInBackground: Bool {
    animationSetupThread == .background
  }

}
