//
//  LALayerView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LALayerView.h"
#import "LAShapeLayerView.h"
#import "LAGroupLayerView.h"

@implementation LALayerView {
  LALayer *_parentModel;
  NSArray *_shapeLayers;
}

- (instancetype)initWithModel:(LALayer *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _layerModel = model;
    [self _setupViewFromModel];
  }
  return self;
}

- (void)_setupViewFromModel {
  self.alpha = _layerModel.opacity.initialValue.floatValue;
  self.layer.position = _layerModel.position.initialPoint;
  self.layer.anchorPoint = _layerModel.anchor.initialPoint;
  self.clipsToBounds = NO;
  
  NSArray *groupItems = _layerModel.shapes;
  NSArray *reversedItems = [[groupItems reverseObjectEnumerator] allObjects];
  LAShapeTransform *currentTransform = nil;
  
  NSMutableArray *shapeLayers = [NSMutableArray array];
  
  for (id item in reversedItems) {
    if ([item isKindOfClass:[LAShapeGroup class]]) {
      LAGroupLayerView *groupLayer = [[LAGroupLayerView alloc] initWithShapeGroup:(LAShapeGroup *)item transform:currentTransform];
      [self.layer addSublayer:groupLayer];
      [shapeLayers addObject:groupLayer];
    } else if ([item isKindOfClass:[LAShapeTransform class]]) {
      currentTransform = (LAShapeTransform *)item;
    }
  }
  
  _shapeLayers = shapeLayers;
}

- (void)_viewtapped {
  NSLog(@"%@", self.layerModel);
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.layer.borderColor = debugModeOn ? [UIColor redColor].CGColor : nil;
  self.layer.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor blueColor] colorWithAlphaComponent:0.2] : [UIColor clearColor];
  
  for (LAGroupLayerView *group in _shapeLayers) {
    group.debugModeOn = debugModeOn;
  }
}

- (void)startAnimation {
  
}

@end
