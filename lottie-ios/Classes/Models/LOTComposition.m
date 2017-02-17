//
//  LOTScene.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTComposition.h"
#import "LOTLayer.h"
#import "LOTAsset.h"
#import "LOTLayerGroup.h"

@implementation LOTComposition {
  NSDictionary *_assetMap;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  NSNumber *width = jsonDictionary[@"w"];
  NSNumber *height = jsonDictionary[@"h"];
  if (width && height) {
    CGRect bounds = CGRectMake(0, 0, width.floatValue, height.floatValue);
    _compBounds = bounds;
  }
  
  _startFrame = [jsonDictionary[@"ip"] copy];
  _endFrame = [jsonDictionary[@"op"] copy];
  _framerate = [jsonDictionary[@"fr"] copy];
  
  if (_startFrame && _endFrame && _framerate) {
    NSInteger frameDuration = _endFrame.integerValue - _startFrame.integerValue;
    NSTimeInterval timeDuration = frameDuration / _framerate.floatValue;
    _timeDuration = timeDuration;
  }
  
  NSArray *layersJSON = jsonDictionary[@"layers"];
  if (layersJSON) {
    _layerGroup = [[LOTLayerGroup alloc] initWithLayerJSON:layersJSON withBounds:_compBounds withFramerate:_framerate];
  }
  
  NSMutableDictionary *assets = [NSMutableDictionary dictionary];
  NSArray *assetArray = jsonDictionary[@"assets"];
  
  for (NSDictionary *assetDictionary in assetArray) {
    NSString *referenceID = assetDictionary[@"id"];
    LOTLayer *layer = [_layerGroup layerForReferenceID:referenceID];
    if (layer) {
      LOTAsset *asset = [[LOTAsset alloc] initWithJSON:assetDictionary withBounds:layer.layerBounds withFramerate:layer.framerate];
      assets[asset.referenceID] = asset;
    }
  }
  _assetMap = assets;
}

- (LOTAsset *)assetModelForID:(NSNumber *)assetID {
  return _assetMap[assetID];
}

@end
