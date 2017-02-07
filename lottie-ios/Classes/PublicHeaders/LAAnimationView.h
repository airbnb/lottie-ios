//
//  LAAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LAAnimationView_Compat.h"

typedef void (^LAAnimationCompletionBlock)(BOOL animationFinished);

@interface LAAnimationView : LAView

+ (instancetype)animationNamed:(NSString *)animationName;
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON;

- (instancetype)initWithContentsOfURL:(NSURL *)url;

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, readonly) CGFloat animationDuration;

- (void)playWithCompletion:(LAAnimationCompletionBlock)completion;
- (void)play;
- (void)pause;

- (void)addSubview:(LAView *)view
      toLayerNamed:(NSString *)layer;

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
@property (nonatomic) LAViewContentMode contentMode;
#endif

@end
