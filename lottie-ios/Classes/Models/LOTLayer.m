//
//  LOTLayer.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTLayer.h"
#import "LOTAnimatableColorValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatableScaleValue.h"
#import "LOTShapeGroup.h"
#import "LOTComposition.h"
#import "LOTHelpers.h"
#import "LOTMask.h"

@implementation LOTLayer

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary fromComposition:(LOTComposition *)composition {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary fromComposition:composition];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary fromComposition:(LOTComposition *)composition {
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  _compBounds = composition.compBounds;
  _framerate = composition.framerate;
  
  NSNumber *layerType = jsonDictionary[@"ty"];
  if (layerType.integerValue <= LOTLayerTypeShape) {
    _layerType = layerType.integerValue;
  } else {
    _layerType = LOTLayerTypeUnknown;
  }
  
  _parentID = [jsonDictionary[@"parent"] copy];
  _inFrame = [jsonDictionary[@"ip"] copy];
  _outFrame = [jsonDictionary[@"op"] copy];
  
  if (_layerType == LOTLayerTypeSolid) {
    _solidWidth = jsonDictionary[@"sw"];
    _solidHeight = jsonDictionary[@"sh"];
    _compBounds = CGRectMake(0, 0, _solidWidth.floatValue, _solidHeight.floatValue);
    NSString *solidColor = jsonDictionary[@"sc"];
    _solidColor = [UIColor LOT_colorWithHexString:solidColor];
  }
  NSDictionary *ks = jsonDictionary[@"ks"];
  
  NSDictionary *opacity = ks[@"o"];
  if (opacity) {
    _opacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:_framerate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
  NSDictionary *rotation = ks[@"r"];
  if (rotation == nil) {
    rotation = ks[@"rz"];
  }
  if (rotation) {
    _rotation = [[LOTAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:_framerate];
    [_rotation remapValueWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_DegreesToRadians(inValue);
    }];
  }
  
  NSDictionary *position = ks[@"p"];
  if ([position[@"s"] boolValue]) {
    // Seperate dimensions
    _positionX = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"x"] frameRate:_framerate];
    _positionY = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"y"] frameRate:_framerate];
  } else {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:_framerate];
  }
  
  NSDictionary *anchor = ks[@"a"];
  if (anchor) {
    _anchor = [[LOTAnimatablePointValue alloc] initWithPointValues:anchor frameRate:_framerate];
    [_anchor remapPointsFromBounds:_compBounds toBounds:CGRectMake(0, 0, 1, 1)];
    _anchor.usePathAnimation = NO;
  }
  
  NSDictionary *scale = ks[@"s"];
  if (scale) {
    _scale = [[LOTAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:_framerate];
  }
  
  _matteType = [jsonDictionary[@"tt"] integerValue];
  
  
  NSMutableArray *masks = [NSMutableArray array];
  for (NSDictionary *maskJSON in jsonDictionary[@"masksProperties"]) {
    LOTMask *mask = [[LOTMask alloc] initWithJSON:maskJSON frameRate:_framerate];
    [masks addObject:mask];
  }
  _masks = masks.count ? masks : nil;
  
  NSMutableArray *shapes = [NSMutableArray array];
  for (NSDictionary *shapeJSON in jsonDictionary[@"shapes"]) {
    id shapeItem = [LOTShapeGroup shapeItemWithJSON:shapeJSON frameRate:_framerate compBounds:_compBounds];
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
