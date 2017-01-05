//
//  LAAnimatablePointValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LAAnimatableValue.h"

@interface LAAnimatablePointValue : NSObject <LAAnimatableValue>

- (instancetype)initWithPointValues:(NSDictionary *)pointValues frameRate:(NSNumber *)frameRate;
- (void)remapPointsFromBounds:(CGRect)frombounds toBounds:(CGRect)toBounds;

@property (nonatomic, readonly) CGPoint initialPoint;
@property (nonatomic, assign) BOOL usePathAnimation;

@end
