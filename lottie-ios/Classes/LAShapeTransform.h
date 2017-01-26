//
//  LAShapeTransform.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LAAnimatableNumberValue;
@class LAAnimatablePointValue;
@class LAAnimatableScaleValue;

@interface LAShapeTransform : NSObject

+ (instancetype)transformIdentityWithCompBounds:(CGRect)compBounds;

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds;

@property (nonatomic, readonly) CGRect compBounds;
@property (nonatomic, readonly) LAAnimatablePointValue *position;
@property (nonatomic, readonly) LAAnimatablePointValue *anchor;
@property (nonatomic, readonly) LAAnimatableScaleValue *scale;
@property (nonatomic, readonly) LAAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LAAnimatableNumberValue *opacity;

@end
