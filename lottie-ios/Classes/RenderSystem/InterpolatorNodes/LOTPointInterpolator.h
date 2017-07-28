//
//  LOTPointInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueInterpolator.h"

@interface LOTPointInterpolator : LOTValueInterpolator

- (CGPoint)pointValueForFrame:(NSNumber *)frame;

@end
