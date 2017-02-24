//
//  LOTLayerGroup.m
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import "LOTLayerGroup.h"
#import "LOTLayer.h"
#import "LOTAssetGroup.h"

@implementation LOTLayerGroup {
  CGRect _bounds;
  NSNumber *_framerate;
  NSDictionary *_modelMap;
  NSDictionary *_referenceIDMap;
  NSArray *layersJSON;
}

- (instancetype)initWithLayerJSON:(NSArray *)layersJSON
                       withBounds:(CGRect)bounds
                    withFramerate:(NSNumber *)framerate
                   withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup {
  self = [super init];
  if (self) {
    _framerate = framerate;
    _bounds = bounds;
    [self _mapFromJSON:layersJSON withAssetGroup:assetGroup];
  }
  return self;
}

- (void)_mapFromJSON:(NSArray *)layersJSON withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup {
  NSMutableArray *layers = [NSMutableArray array];
  NSMutableDictionary *modelMap = [NSMutableDictionary dictionary];
  NSMutableDictionary *referenceMap = [NSMutableDictionary dictionary];
  
  for (NSDictionary *layerJSON in layersJSON) {
    LOTLayer *layer = [[LOTLayer alloc] initWithJSON:layerJSON withCompBounds:_bounds withFramerate:_framerate];
    [layers addObject:layer];
    modelMap[layer.layerID] = layer;
    if (layer.referenceID && assetGroup) {
      referenceMap[layer.referenceID] = layer;
      [assetGroup buildAssetNamed:layer.referenceID withBounds:layer.layerBounds andFramerate:layer.framerate];
      if (layer.layerType == LOTLayerTypeImage) {
        LOTAsset *imageAsset = [assetGroup assetModelForID:layer.referenceID];
        if (imageAsset) {
          [layer setImageAsset:imageAsset];
        }
      }
    }
  }
  
  _referenceIDMap = referenceMap;
  _modelMap = modelMap;
  _layers = layers;
}

- (LOTLayer *)layerModelForID:(NSNumber *)layerID {
  return _modelMap[layerID];
}

- (LOTLayer *)layerForReferenceID:(NSString *)referenceID {
  return _referenceIDMap[referenceID];
}

@end
