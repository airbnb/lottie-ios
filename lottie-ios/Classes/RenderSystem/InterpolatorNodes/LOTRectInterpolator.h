//
//  LOTRectInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueInterpolator.h"

@interface LOTRectInterpolator : LOTValueInterpolator

- (CGRect)rectValueForFrame:(NSNumber *)frame;

@end
