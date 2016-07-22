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
  
  NSArray *reversedItems = [[_sceneModel.layers reverseObjectEnumerator] allObjects];

  for (LALayer *layer in reversedItems) {
    LALayerView *layerView = [[LALayerView alloc] initWithModel:layer inComposition:_sceneModel];
    layerMap[layer.layerID] = layerView;
    [self.layer addSublayer:layerView];
  }
  _layerMap = layerMap;
}

- (void)_viewtapped {
  self.debugModeOn = !self.debugModeOn;
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
}

- (void)play {
  [CATransaction begin];
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView play];
  }
  [CATransaction commit];
}

- (void)pause {
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView pause];
  }
}

- (void)setAnimationProgress:(CGFloat)animationProgress {
  _animationProgress = animationProgress;
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView setAnimationProgress:animationProgress];
  }
}

- (void)setLoopAnimation:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView setLoopAnimation:loopAnimation];
  }
}

- (void)setAutoReverseAnimation:(BOOL)autoReverseAnimation {
  _autoReverseAnimation = autoReverseAnimation;
  for (LALayerView *layerView in _layerMap.allValues) {
    [layerView setAutoReverseAnimation:autoReverseAnimation];
  }
}

@end
