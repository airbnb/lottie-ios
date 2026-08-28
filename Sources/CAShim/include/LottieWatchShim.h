#import <Foundation/Foundation.h>

/// Declared here rather than by importing WatchKit.
///
/// WatchKit re-exports UIKit, which re-exports the SDK's CoreAnimation
/// declarations - the ones marked API_UNAVAILABLE(watchos) - and because Swift
/// compiles a module as a whole, one file importing WatchKit makes those gated
/// declarations win over this shim for EVERY file in Lottie. The symbol is
/// resolved at link time against WatchKit, which the app links anyway.
extern BOOL WKAccessibilityIsReduceMotionEnabled(void);
