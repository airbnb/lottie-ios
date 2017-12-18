//
//  LOTSizeInterpolator.h
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueInterpolator.h"
#import "LOTValueCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface LOTSizeInterpolator : LOTValueInterpolator

- (CGSize)sizeValueForFrame:(NSNumber *)frame;

@property (nonatomic, strong, nullable) LOTSizeValueCallback *sizeCallback;

@end

NS_ASSUME_NONNULL_END
