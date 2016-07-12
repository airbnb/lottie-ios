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

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  
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
  
  NSDictionary *opacity = jsonDictionary[@"ks.o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity];
  }
  
  NSDictionary *rotation = jsonDictionary[@"ks.r"];
  if (rotation) {
    _rotation = [[LAAnimatableNumberValue alloc] initWithNumberValues:rotation];
  }
  
  NSDictionary *position = jsonDictionary[@"ks.p"];
  if (position) {
    _position = [[LAAnimatablePointValue alloc] initWithPointValues:position];
  }
  
  NSDictionary *anchor = jsonDictionary[@"ks.a"];
  if (anchor) {
    _anchor = [[LAAnimatablePointValue alloc] initWithPointValues:anchor];
  }
  
  NSDictionary *scale = jsonDictionary[@"ks.s"];
  if (scale) {
    _scale = [[LAAnimatableScaleValue alloc] initWithScaleValues:scale];
  }
  
  NSMutableArray *masks = [NSMutableArray array];
  for (NSDictionary *maskJSON in jsonDictionary[@"masksProperties"]) {
    LAMask *mask = [[LAMask alloc] initWithJSON:maskJSON frameRate:frameRate];
    [masks addObject:mask];
  }
  _masks = masks;
  
  NSMutableArray *shapes = [NSMutableArray array];
  for (NSDictionary *shapeJSON in jsonDictionary[@"shapes"]) {
    LAShapeGroup *group = [[LAShapeGroup alloc] initWithJSON:shapeJSON frameRate:frameRate];
    [shapes addObject:group];
  }
  _shapes = shapes;
}

@end
