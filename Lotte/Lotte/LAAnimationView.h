//
//  LAAnimationView
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//


// TODO
// - Enable auto reverse animation
// - Support repeater objects
// - Animated Button
// - Completion Block
// - Merged Paths
// - Color conversion from older version
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
// Currently Not Supported.
@property (nonatomic, assign) BOOL autoReverseAnimation;

@property (nonatomic, assign) CFTimeInterval debugBeginTime;
@property (nonatomic, assign) CFTimeInterval debugTimeOffset;
@property (nonatomic, assign) CGFloat debugDuration;
@property (nonatomic, assign) CGFloat debugSpeed;

- (void)playWithCompletion:(void (^)(void))completion;
- (void)play;
- (void)pause;

@end
