//
//  LOTCompositionLayer.m
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import "LOTCompositionLayer.h"

@implementation LOTCompositionLayer {
  
}

- (instancetype)initWithLayerGroup:(LOTLayerGroup *)layerGroup {
  self = [super init];
  if (self) {
    self.masksToBounds = YES;
    [self _setupWithLayerGroup:layerGroup];
  }
  return self;
}

- (void)_setupWithLayerGroup:(LOTLayerGroup *)layerGroup {
  if (_customLayers) {
    for (LOTCustomChild *child in _customLayers) {
      [child.childView.layer removeFromSuperlayer];
    }
    _customLayers = nil;
  }
  
  if (_layerMap) {
    _layerMap = nil;
    [_animationContainer removeAllAnimations];
    [_animationContainer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  }
  
  if (_layerNameMap) {
    _layerNameMap = nil;
  }
  
  _animationContainer.transform = CATransform3DIdentity;
  _animationContainer.bounds = _sceneModel.compBounds;
  
  NSMutableDictionary *layerMap = [NSMutableDictionary dictionary];
  NSMutableDictionary *layerNameMap = [NSMutableDictionary dictionary];
  
  NSArray *reversedItems = [[_sceneModel.layerGroup.layers reverseObjectEnumerator] allObjects];
  
  LOTLayerView *maskedLayer = nil;
  for (LOTLayer *layer in reversedItems) {
    LOTLayerView *layerView = [[LOTLayerView alloc] initWithModel:layer inLayerGroup:_sceneModel.layerGroup];
    layerMap[layer.layerID] = layerView;
    layerNameMap[layer.layerName] = layerView;
    if (maskedLayer) {
      maskedLayer.mask = layerView;
      maskedLayer = nil;
    } else {
      if (layer.matteType == LOTMatteTypeAdd) {
        maskedLayer = layerView;
      }
      [_animationContainer addSublayer:layerView];
    }
  }
  _layerMap = layerMap;
  _layerNameMap = layerNameMap;
}

@end
