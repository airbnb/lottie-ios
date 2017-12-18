//
//  LOTNumberInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTValueInterpolator.h"
#import "LOTValueCallback.h"

NS_ASSUME_NONNULL_BEGIN
@interface LOTNumberInterpolator : LOTValueInterpolator

- (CGFloat)floatValueForFrame:(NSNumber *)frame;

@property (nonatomic, strong, nullable) LOTNumberValueCallback *numberCallback;

@end

NS_ASSUME_NONNULL_END
