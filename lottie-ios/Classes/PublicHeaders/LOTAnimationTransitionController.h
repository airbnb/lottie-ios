//
//  LOTAnimationTransitionController.h
//  Lottie
//
//  Created by Brandon Withrow on 1/18/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/** LOTAnimationTransitionController
 *
 *  This class creates a custom UIViewController transisiton animation
 *  using a Lottie animation to transition between two view controllers
 *  The transition can use custom defined layers in After Effects for to/from
 * 
 *  When referencing After Effects layers the animator masks the to/from viewController
 *  with the referenced layer.
 *
 */

@interface LOTAnimationTransitionController : NSObject <UIViewControllerAnimatedTransitioning>

/**
 The initializer to create a new transition animation.
 
 @param animation The name of the Lottie Animation to load for the transition
 
 @param fromLayer The name of the custom layer to mask the fromVC screenshot with. 
 If no layer is specified then the screenshot is added behind the Lottie Animation
 
 @param toLayer The name of the custom layer to mask the toVC screenshot with.
 If no layer is specified then the screenshot is added behind the Lottie Animation
 and a fade transition is performed along with the Lottie animation.

 */
- (nonnull instancetype)initWithAnimationNamed:(nonnull NSString *)animation
                        fromLayerNamed:(nullable NSString *)fromLayer
                          toLayerNamed:(nullable NSString *)toLayer;

/**
 The initializer to create a new transition animation.
 
 @param animation The name of the Lottie Animation to load for the transition
 
 @param fromLayer The name of the custom layer to mask the fromVC screenshot with.
 If no layer is specified then the screenshot is added behind the Lottie Animation
 
 @param toLayer The name of the custom layer to mask the toVC screenshot with.
 If no layer is specified then the screenshot is added behind the Lottie Animation
 and a fade transition is performed along with the Lottie animation.
 
 @param bundle custom bundle to load animation and images, if no bundle is specified will load
 from mainBundle
 */
- (instancetype)initWithAnimationNamed:(NSString *)animation
                        fromLayerNamed:(NSString *)fromLayer
                          toLayerNamed:(NSString *)toLayer
                              inBundle:(NSBundle *)bundle;

@end

#endif
