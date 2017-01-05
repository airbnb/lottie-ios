//
//  LAAnimatableBoundsValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LAAnimatableValue.h"

@interface LAAnimatableBoundsValue : NSObject <LAAnimatableValue>

- (instancetype)initWithSizeValues:(NSDictionary *)sizeValue frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) CGRect initialBounds;

@end
