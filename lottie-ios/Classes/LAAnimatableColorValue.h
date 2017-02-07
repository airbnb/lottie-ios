//
//  LAAnimatableColorValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "LAAnimatableValue.h"
#import "LAPlatformCompat.h"

@interface LAAnimatableColorValue : NSObject <LAAnimatableValue>

- (instancetype)initWithColorValues:(NSDictionary *)colorValues frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) UIColor *initialColor;

@end
