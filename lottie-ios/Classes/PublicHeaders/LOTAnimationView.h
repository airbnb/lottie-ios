//
//  LOTAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTAnimationView_Compat.h"

typedef void (^LOTAnimationCompletionBlock)(BOOL animationFinished);

@interface LOTAnimationView : LOTView

+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName NS_SWIFT_NAME(init(name:));
+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName inBundle:(nonnull NSBundle *)bundle NS_SWIFT_NAME(init(name:bundle:));
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON NS_SWIFT_NAME(init(json:));
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON inBundle:(NSBundle *)bundle NS_SWIFT_NAME(init(json:bundle:));

- (nonnull instancetype)initWithContentsOfURL:(nonnull NSURL *)url;

+ (instancetype)animationWithFilePath:(NSString *)filePath NS_SWIFT_NAME(init(filePath:));

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, readonly) CGFloat animationDuration;

- (void)playWithCompletion:(nullable LOTAnimationCompletionBlock)completion;
- (void)play;
- (void)pause;

- (void)addSubview:(nonnull LOTView *)view
      toLayerNamed:(nonnull NSString *)layer;

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
@property (nonatomic) LOTViewContentMode contentMode;
#endif

@end
