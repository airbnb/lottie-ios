//
//  LACompView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LACompView.h"

@implementation LACompView

- (instancetype)initWithModel:(LAComposition *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _sceneModel = model;
    for (LALayer *layer in model.layers) {
      LALayerView *layerView = [[LALayerView alloc] initWithModel:layer];
      [self addSubview:layerView];
      [self sendSubviewToBack:layerView];
    }
    self.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_viewtapped)];
    [self addGestureRecognizer:tapGesture];
  }
  return self;
}

- (void)_viewtapped {
  self.debugModeOn = !self.debugModeOn;
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  for (UIView *child in self.subviews) {
    if ([child isKindOfClass:[LALayerView class]]) {
      [(LALayerView *)child setDebugModeOn:debugModeOn];
      child.alpha = debugModeOn ? 0.5 : 1;
    }
  }
}

@end
