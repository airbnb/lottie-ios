//
//  LOTShapeTransform.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@class LOTAnimatableNumberValue;
@class LOTAnimatablePointValue;
@class LOTAnimatableScaleValue;

@interface LOTShapeTransform : NSObject

+ (instancetype)transformIdentityWithCompBounds:(CGRect)compBounds;

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds;

- (CATransform3D)transformForFrame:(NSNumber *)frame;

@property (nonatomic, readonly) CGRect compBounds;
@property (nonatomic, readonly) LOTAnimatablePointValue *position;
@property (nonatomic, readonly) LOTAnimatablePointValue *anchor;
@property (nonatomic, readonly) LOTAnimatableScaleValue *scale;
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;

@end
