//
//  LOTLayer.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTLayer.h"
#import "LOTAsset.h"
#import "LOTAnimatableColorValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatableScaleValue.h"
#import "LOTShapeGroup.h"
#import "LOTComposition.h"
#import "LOTHelpers.h"
#import "LOTMask.h"
#import "LOTHelpers.h"

@implementation LOTLayer

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withCompBounds:(CGRect)compBounds
               withFramerate:(NSNumber *)framerate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary withCompBounds:compBounds withFramerate:framerate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary
      withCompBounds:(CGRect)compBounds
       withFramerate:(NSNumber *)framerate {
  _parentCompBounds = compBounds;
  _layerName = [jsonDictionary[@"nm"] copy];
  _layerID = [jsonDictionary[@"ind"] copy];
  
  NSNumber *layerType = jsonDictionary[@"ty"];
  _layerType = layerType.integerValue;
  
  if (jsonDictionary[@"refId"]) {
    _referenceID = [jsonDictionary[@"refId"] copy];
  }
  
  _parentID = [jsonDictionary[@"parent"] copy];
  
  _inFrame = [jsonDictionary[@"ip"] copy];
  _outFrame = [jsonDictionary[@"op"] copy];
  _framerate = framerate;
  
  _layerWidth = @(compBounds.size.width);
  _layerHeight = @(compBounds.size.height);
  
  if (_layerType == LOTLayerTypePrecomp ||
      _layerType == LOTLayerTypeImage) {
    _layerHeight = [jsonDictionary[@"h"] copy];
    _layerWidth = [jsonDictionary[@"w"] copy];
  }
  
  if (_layerType == LOTLayerTypeSolid) {
    _layerWidth = jsonDictionary[@"sw"];
    _layerHeight = jsonDictionary[@"sh"];
    NSString *solidColor = jsonDictionary[@"sc"];
    _solidColor = [UIColor LOT_colorWithHexString:solidColor];
  }
  
  _layerBounds = CGRectMake(0, 0, _layerWidth.floatValue, _layerHeight.floatValue);
  
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
    // Separate dimensions
    _positionX = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"x"] frameRate:_framerate];
    _positionY = [[LOTAnimatableNumberValue alloc] initWithNumberValues:position[@"y"] frameRate:_framerate];
  } else {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:_framerate];
  }
  
  NSDictionary *anchor = ks[@"a"];
  if (anchor) {
    _anchor = [[LOTAnimatablePointValue alloc] initWithPointValues:anchor frameRate:_framerate];
    [_anchor remapPointsFromBounds:_layerBounds toBounds:CGRectMake(0, 0, 1, 1)];
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
    id shapeItem = [LOTShapeGroup shapeItemWithJSON:shapeJSON frameRate:_framerate compBounds:_layerBounds];
    if (shapeItem) {
      [shapes addObject:shapeItem];
    }
  }
  _shapes = shapes;
  
  _hasInAnimation = _inFrame.integerValue > 0;
  
  NSMutableArray *keys = [NSMutableArray array];
  NSMutableArray *keyTimes = [NSMutableArray array];
  CGFloat layerLength = _outFrame.integerValue;
  _layerDuration = (layerLength / _framerate.floatValue);
  
  if (_hasInAnimation) {
    [keys addObject:@1];
    [keyTimes addObject:@0];
    [keys addObject:@0];
    CGFloat inTime = _inFrame.floatValue / layerLength;
    [keyTimes addObject:@(inTime)];
  } else {
    [keys addObject:@0];
    [keyTimes addObject:@0];
  }
  
  [keys addObject:@1];
  [keyTimes addObject:@1];

  
  
  _inOutKeyTimes = keyTimes;
  _inOutKeyframes = keys;
}

- (void)setImageAsset:(LOTAsset *)imageAsset {
  _imageAsset = imageAsset;
  [_anchor remapPointsFromBounds:CGRectMake(0, 0, 1, 1) toBounds:_layerBounds];
  _layerBounds = CGRectMake(0, 0, imageAsset.assetWidth.floatValue, imageAsset.assetHeight.floatValue);
  [_anchor remapPointsFromBounds:_layerBounds toBounds:CGRectMake(0, 0, 1, 1)];
}

- (NSString*)description {
    NSMutableString *text = [[super description] mutableCopy];
    [text appendFormat:@" %@ id: %d pid: %d frames: %d-%d", _layerName, (int)_layerID.integerValue, (int)_parentID.integerValue,
     (int)_inFrame.integerValue, (int)_outFrame.integerValue];
    return text;
}

@end
