//
//  LALayer.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LALayer.h"
#import "LAAnimatableColorValue.h"
#import "LAAnimatablePointValue.h"
#import "LAAnimatableNumberValue.h"
#import "LAAnimatableScaleValue.h"
#import "LAShapeGroup.h"
#import "LAComposition.h"
#import "LAHelpers.h"
#import "LAMask.h"

@implementation LALayer

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary fromComposition:(LAComposition *)composition {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary fromComposition:composition];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary fromComposition:(LAComposition *)composition {
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  _compBounds = composition.compBounds;
  _framerate = composition.framerate;
  
  NSNumber *layerType = jsonDictionary[@"ty"];
  if (layerType.integerValue <= LALayerTypeShape) {
    _layerType = layerType.integerValue;
  } else {
    _layerType = LALayerTypeUnknown;
  }
  
  _parentID = [jsonDictionary[@"parent"] copy];
  _inFrame = [jsonDictionary[@"ip"] copy];
  _outFrame = [jsonDictionary[@"op"] copy];
  
  if (_layerType == LALayerTypeSolid) {
    _solidWidth = jsonDictionary[@"sw"];
    _solidHeight = jsonDictionary[@"sh"];
    _compBounds = CGRectMake(0, 0, _solidWidth.floatValue, _solidHeight.floatValue);
    NSString *solidColor = jsonDictionary[@"sc"];
    _solidColor = [UIColor colorWithHexString:solidColor];
  }
  NSDictionary *ks = jsonDictionary[@"ks"];
  
  NSDictionary *opacity = ks[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:_framerate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
  NSDictionary *rotation = ks[@"r"];
  if (rotation) {
    _rotation = [[LAAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:_framerate];
    [_rotation remapValueWithBlock:^CGFloat(CGFloat inValue) {
      return DegreesToRadians(inValue);
    }];
  }
  
  NSDictionary *position = ks[@"p"];
  if (position) {
    _position = [[LAAnimatablePointValue alloc] initWithPointValues:position frameRate:_framerate];
  }
  
  NSDictionary *anchor = ks[@"a"];
  if (anchor) {
    _anchor = [[LAAnimatablePointValue alloc] initWithPointValues:anchor frameRate:_framerate];
    [_anchor remapPointsFromBounds:_compBounds toBounds:CGRectMake(0, 0, 1, 1)];
    _anchor.usePathAnimation = NO;
  }
  
  NSDictionary *scale = ks[@"s"];
  if (scale) {
    _scale = [[LAAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:_framerate];
  }
  
  _matteType = [jsonDictionary[@"tt"] integerValue];
  
  
  NSMutableArray *masks = [NSMutableArray array];
  for (NSDictionary *maskJSON in jsonDictionary[@"masksProperties"]) {
    LAMask *mask = [[LAMask alloc] initWithJSON:maskJSON frameRate:_framerate];
    [masks addObject:mask];
  }
  _masks = masks.count ? masks : nil;
  
  NSMutableArray *shapes = [NSMutableArray array];
  for (NSDictionary *shapeJSON in jsonDictionary[@"shapes"]) {
    id shapeItem = [LAShapeGroup shapeItemWithJSON:shapeJSON frameRate:_framerate compBounds:_compBounds];
    if (shapeItem) {
      [shapes addObject:shapeItem];
    }
  }
  _shapes = shapes;
  
  _hasInAnimation = (_inFrame.integerValue > composition.startFrame.integerValue);
  _hasOutAnimation = (_outFrame.integerValue < composition.endFrame.integerValue);
  _hasInOutAnimation = _hasInAnimation || _hasOutAnimation;
  if (_hasInOutAnimation) {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *keyTimes = [NSMutableArray array];
    CGFloat compLength = composition.endFrame.floatValue - composition.startFrame.floatValue;
    
    if (_hasInAnimation) {
      [keys addObject:@1];
      [keyTimes addObject:@0];
      [keys addObject:@0];
      CGFloat inTime = _inFrame.floatValue / compLength;
      [keyTimes addObject:@(inTime)];
    } else {
      [keys addObject:@0];
      [keyTimes addObject:@0];
    }
    
    if (_hasOutAnimation) {
      [keys addObject:@1];
      CGFloat outTime = _outFrame.floatValue / compLength;
      [keyTimes addObject:@(outTime)];
      [keys addObject:@1];
      [keyTimes addObject:@1];
    } else {
      [keys addObject:@0];
      [keyTimes addObject:@1];
    }
    
    _compDuration = composition.timeDuration;
    _inOutKeyTimes = keyTimes;
    _inOutKeyframes = keys;
  }
}

@end
