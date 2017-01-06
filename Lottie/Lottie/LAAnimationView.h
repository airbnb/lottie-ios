//
//  LAAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAAnimationView : UIView

+ (instancetype)animationNamed:(NSString *)animationName;
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON;

- (instancetype)initWithContentsOfURL:(NSURL *)url;

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) CGFloat animationProgress;
@property (nonatomic, assign) CGFloat animationSpeed;

- (void)playWithCompletion:(void (^)(void))completion;
- (void)play;
- (void)pause;

@end
