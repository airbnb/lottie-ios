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

+ (instancetype)animationNamed:(NSString *)animationName;
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON;

- (instancetype)initWithContentsOfURL:(NSURL *)url;

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, readonly) CGFloat animationDuration;

- (void)playWithCompletion:(LOTAnimationCompletionBlock)completion;
- (void)play;
- (void)pause;

- (void)addSubview:(LOTView *)view
      toLayerNamed:(NSString *)layer;

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
@property (nonatomic) LOTViewContentMode contentMode;
#endif

@end
