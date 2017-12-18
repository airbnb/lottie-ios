//
//  LOTColorInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueInterpolator.h"
#import "LOTPlatformCompat.h"
#import "LOTValueCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface LOTColorInterpolator : LOTValueInterpolator

- (UIColor *)colorForFrame:(NSNumber *)frame;

@property (nonatomic, strong, nullable) LOTColorValueCallback *colorCallback;

@end

NS_ASSUME_NONNULL_END
