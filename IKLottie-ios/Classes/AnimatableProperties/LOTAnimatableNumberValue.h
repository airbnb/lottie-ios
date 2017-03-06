//
//  LOTAnimatableNumberValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "LOTAnimatableValue.h"

@interface LOTAnimatableNumberValue : NSObject <LOTAnimatableValue>

- (instancetype)initWithNumberValues:(NSDictionary *)numberValues frameRate:(NSNumber *)frameRate;
- (void)remapValuesFromMin:(NSNumber *)fromMin
                   fromMax:(NSNumber *)fromMax
                     toMin:(NSNumber *)toMin
                     toMax:(NSNumber *)toMax;

- (void)remapValueWithBlock:(CGFloat (^)(CGFloat inValue))remapBlock;

@property (nonatomic, readonly) NSNumber *initialValue;

@end
