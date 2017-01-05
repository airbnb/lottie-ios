//
//  LAAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//


// TODO

// - Support repeater objects
// - Animated Button
// - Merged Paths
// - Line start offset
// - Round Rect with dashed lines

#import <UIKit/UIKit.h>

@interface LAAnimationView : UIView

+ (instancetype)animationNamed:(NSString *)animationName;
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON;

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, assign) CGFloat animationSpeed;

- (void)playWithCompletion:(void (^)(void))completion;
- (void)play;
- (void)pause;

@end
