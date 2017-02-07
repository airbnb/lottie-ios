//
//  LOTShapeCircle.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LOTAnimatablePointValue;
@class LOTAnimatableScaleValue;

@interface LOTShapeCircle : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LOTAnimatablePointValue *position;
@property (nonatomic, readonly) LOTAnimatablePointValue *size;

@end
