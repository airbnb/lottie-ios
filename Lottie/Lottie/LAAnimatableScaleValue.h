//
//  LAAnimatableScaleValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LAAnimatableValue.h"

@interface LAAnimatableScaleValue : NSObject <LAAnimatableValue>

- (instancetype)initWithScaleValues:(NSDictionary *)scaleValues frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) CATransform3D initialScale;

@end
