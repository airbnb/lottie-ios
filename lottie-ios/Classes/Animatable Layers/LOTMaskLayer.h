//
//  LOTMaskLayer.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/22/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableLayer.h"
#import "LOTModels.h"

@interface LOTMaskLayer : LOTAnimatableLayer

- (instancetype)initWithMasks:(NSArray<LOTMask *> *)masks inComposition:(LOTComposition *)comp;

@property (nonatomic, readonly) NSArray<LOTMask *> *masks;


@end
