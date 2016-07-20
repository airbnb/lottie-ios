//
//  LACompView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LACompView.h"

@implementation LACompView {
  NSDictionary *_layerMap;
}

- (instancetype)initWithModel:(LAComposition *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _sceneModel = model;
    [self _buildSubviewsFromModel];
    self.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_viewtapped)];
    [self addGestureRecognizer:tapGesture];
  }
  return self;
}

- (void)_buildSubviewsFromModel {
  NSMutableDictionary *layerMap = [NSMutableDictionary dictionary];
  for (LALayer *layer in _sceneModel.layers) {
    LALayerView *layerView = [[LALayerView alloc] initWithModel:layer inComposition:_sceneModel];
    layerMap[layer.layerID] = layerView;
    [self addSubview:layerView];
    [self sendSubviewToBack:layerView];
  }
  _layerMap = layerMap;
}

- (void)_viewtapped {
  self.debugModeOn = !self.debugModeOn;
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  for (LALayerView *child in _layerMap.allValues) {
    if ([child isKindOfClass:[LALayerView class]]) {
      [child setDebugModeOn:debugModeOn];
      child.alpha = debugModeOn ? 0.5 : 1;
    }
  }
}

- (void)play {
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView startAnimation];
  }
}

@end
