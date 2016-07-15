//
//  LAAnimatablePointValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAAnimatablePointValue : NSObject

- (instancetype)initWithPointValues:(NSDictionary *)pointValues;

@property (nonatomic, readonly) CGPoint initialPoint;
@property (nonatomic, readonly) UIBezierPath *animationPath;
@property (nonatomic, readonly) NSArray<NSValue *> *pointKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;

- (void)remapPointsFromBounds:(CGRect)frombounds toBounds:(CGRect)toBounds;

@end
