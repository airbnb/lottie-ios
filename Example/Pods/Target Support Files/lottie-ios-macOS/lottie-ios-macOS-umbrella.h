#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LOTAnimationCache.h"
#import "LOTAnimationView.h"
#import "LOTAnimationView_Compat.h"
#import "LOTBlockCallback.h"
#import "LOTComposition.h"
#import "LOTInterpolatorCallback.h"
#import "LOTKeypath.h"
#import "Lottie.h"
#import "LOTValueCallback.h"
#import "LOTValueDelegate.h"

FOUNDATION_EXPORT double LottieVersionNumber;
FOUNDATION_EXPORT const unsigned char LottieVersionString[];

