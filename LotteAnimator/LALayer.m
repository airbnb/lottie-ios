//
//  LALayer.m
//  LotteAnimator
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

@implementation LALayer

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate compBounds:compBounds];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  _compBounds = compBounds;
  
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
    // TODO Solids.
    
  }
  NSDictionary *ks = jsonDictionary[@"ks"];
  
  NSDictionary *opacity = ks[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:frameRate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
  NSDictionary *rotation = ks[@"r"];
  if (rotation) {
    _rotation = [[LAAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:frameRate];
  }
  
  NSDictionary *position = ks[@"p"];
  if (position) {
    _position = [[LAAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
  }
  
  NSDictionary *anchor = ks[@"a"];
  if (anchor) {
    _anchor = [[LAAnimatablePointValue alloc] initWithPointValues:anchor frameRate:frameRate];
    [_anchor remapPointsFromBounds:compBounds toBounds:CGRectMake(0, 0, 1, 1)];
  }
  
  NSDictionary *scale = ks[@"s"];
  if (scale) {
    _scale = [[LAAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:frameRate];
  }
  
  NSMutableArray *masks = [NSMutableArray array];
  for (NSDictionary *maskJSON in jsonDictionary[@"masksProperties"]) {
    LAMask *mask = [[LAMask alloc] initWithJSON:maskJSON frameRate:frameRate];
    [masks addObject:mask];
  }
  _masks = masks;
  
  NSMutableArray *shapes = [NSMutableArray array];
  for (NSDictionary *shapeJSON in jsonDictionary[@"shapes"]) {
    LAShapeGroup *group = [[LAShapeGroup alloc] initWithJSON:shapeJSON frameRate:frameRate compBounds:compBounds];
    [shapes addObject:group];
  }
  _shapes = shapes;
}

@end
