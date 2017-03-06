//
//  LOTMaskLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/22/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTMaskLayer.h"
#import "CAAnimationGroup+LOTAnimatableGroup.h"

@implementation LOTMaskLayer {
  LOTLayer *_layer;
  NSArray *_maskLayers;
}

- (instancetype)initWithMasks:(NSArray<LOTMask *> *)masks inLayer:(LOTLayer *)layer {
  self = [super initWithLayerDuration:layer.layerDuration];
  if (self) {
    _masks = masks;
    _layer = layer;
    [self _setupViewFromModel];
  }
  return self;
}

- (void)_setupViewFromModel {
  NSMutableArray *maskLayers = [NSMutableArray array];
  
  for (LOTMask *mask in _masks) {
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.path = mask.maskPath.initialShape.CGPath;
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    maskLayer.opacity = mask.opacity.initialValue.floatValue;
    [self addSublayer:maskLayer];
    CAAnimationGroup *animGroup = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : mask.opacity,
                                                                                                        @"path" : mask.maskPath}];
    if (animGroup) {
      [maskLayer addAnimation:animGroup forKey:@""];
    }
    [maskLayers addObject:maskLayer];
  }
  _maskLayers = maskLayers;
}

@end
