//
//  LOTColorInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueInterpolator.h"
#import "LOTPlatformCompat.h"

NS_ASSUME_NONNULL_BEGIN

@interface LOTColorInterpolator : LOTValueInterpolator

- (UIColor *)colorForFrame:(NSNumber *)frame;

@end

NS_ASSUME_NONNULL_END
