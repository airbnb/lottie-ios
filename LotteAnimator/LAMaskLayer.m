//
//  LAMaskLayer.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/22/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAMaskLayer.h"

@implementation LAMaskLayer {
  LAComposition *_composition;
}

- (instancetype)initWithMasks:(NSArray<LAMask *> *)masks inComposition:(LAComposition *)comp {
  self = [super initWithDuration:comp.timeDuration];
  if (self) {
    _masks = masks;
    _composition = comp;
    [self _setupViewFromModel];
  }
  return self;
}

- (void)_setupViewFromModel {
  
}

@end
