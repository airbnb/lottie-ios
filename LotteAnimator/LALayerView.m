//
//  LALayerView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LALayerView.h"
#import "LAShapeLayerView.h"

@implementation LALayerView {
  LALayer *_parentModel;
}

- (instancetype)initWithModel:(LALayer *)model
                  parentModel:(LALayer *)parentModel
                   compBounds:(CGRect)compBounds {
  self = [super initWithFrame:compBounds];
  if (self) {
    _layerModel = model;
    _parentModel = parentModel;
    [self _setupViewFromModel];
  }
  return self;
}

- (void)_setupViewFromModel {
  
  
  self.alpha = _layerModel.opacity.initialValue.floatValue;
  self.layer.position = _layerModel.position.initialPoint;
  self.layer.anchorPoint = _layerModel.anchor.initialPoint;
  self.clipsToBounds = NO;
  for (LAShapeGroup *group in _layerModel.shapes) {
    [self _setupShapeGroup:group];
  }
}

- (void)_setupShapeGroup:(LAShapeGroup *)shapeGroup {
  NSArray *groupItems = shapeGroup.items;
  NSArray *reversedItems = [[groupItems reverseObjectEnumerator] allObjects];
  
  LAShapeFill *currentFill;
  LAShapeStroke *currentStroke;
  LAShapeTransform *currentTransform;
  for (id item in reversedItems) {
    if ([item isKindOfClass:[LAShapeTransform class]]) {
      currentTransform = item;
    } else if ([item isKindOfClass:[LAShapeStroke class]]) {
      currentStroke = item;
    } else if ([item isKindOfClass:[LAShapeFill class]]) {
      currentFill = item;
    } else if ([item isKindOfClass:[LAShapePath class]]) {
      LAShapePath *shapePath = (LAShapePath *)item;
      LAShapeLayerView *shapeLayer = [[LAShapeLayerView alloc] initWithShape:shapePath
                                                                        fill:currentFill
                                                                      stroke:currentStroke
                                                                   transform:currentTransform];
      [self.layer addSublayer:shapeLayer];
    }
  }
}

- (void)_viewtapped {
  NSLog(@"%@", self.layerModel);
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.layer.borderColor = debugModeOn ? [UIColor redColor].CGColor : nil;
  self.layer.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor blueColor] colorWithAlphaComponent:0.2] : [UIColor clearColor];
}

@end
