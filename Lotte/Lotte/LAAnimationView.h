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
// - Line caps
// - Completion Block
// - Merged Paths
// - Color conversion from older version
// - Line start offset

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

- (void)playWithCompletion:(void (^)(void))completion;
- (void)play;
- (void)pause;

@end
