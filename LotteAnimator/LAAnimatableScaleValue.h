//
//  LAAnimatableScaleValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAAnimatableScaleValue : NSObject

- (instancetype)initWithScaleValues:(NSDictionary *)scaleValues frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) CATransform3D initialScale;

@property (nonatomic, readonly) NSArray<NSValue *> *scaleKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSTimeInterval delay;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) BOOL hasAnimation;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;
@property (nonatomic, readonly) NSNumber *frameRate;

- (CAKeyframeAnimation *)animationForKeyPath:(NSString *)keypath;

@end
