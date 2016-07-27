//
//  LACompView.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LACompView : UIView

+ (instancetype)animationNamed:(NSString *)animationName;
+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON;

@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) BOOL autoReverseAnimation;
@property (nonatomic, assign) CGFloat animationProgress;

- (void)playWithCompletion:(void (^)(void))completion;
- (void)play;
- (void)pause;

@end
