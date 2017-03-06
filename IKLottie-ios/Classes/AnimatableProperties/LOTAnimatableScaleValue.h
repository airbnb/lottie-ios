//
//  LOTAnimatableScaleValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTAnimatableValue.h"

@interface LOTAnimatableScaleValue : NSObject <LOTAnimatableValue>

- (instancetype)initWithScaleValues:(NSDictionary *)scaleValues frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) CATransform3D initialScale;

@end
