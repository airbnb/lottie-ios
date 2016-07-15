//
//  LAGroupLayerView.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAGroupLayerView.h"
#import "LAShapeLayerView.h"

@implementation LAGroupLayerView {
  LAShapeGroup *_shapeGroup;
  LAShapeTransform *_shapeTransform;
}

- (instancetype)initWithShapeGroup:(LAShapeGroup *)shapeGroup
                         transform:(LAShapeTransform *)transform  {
  self = [super init];
  if (self) {
    _shapeGroup = shapeGroup;
    _shapeTransform = transform;
    [self _setupShapeGroup];
  }
  return self;
}

- (void)_setupShapeGroup {
  if (_shapeTransform) {
    self.frame = _shapeTransform.compBounds;
    self.anchorPoint = _shapeTransform.anchor.initialPoint;
    self.position = _shapeTransform.position.initialPoint;
    self.opacity = _shapeTransform.opacity.initialValue.floatValue;
  }
  
  NSArray *groupItems = _shapeGroup.items;
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
      [self addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LAShapeGroup class]]) {
      LAShapeGroup *shapeGroup = (LAShapeGroup *)item;
      LAGroupLayerView *groupLayer = [[LAGroupLayerView alloc] initWithShapeGroup:shapeGroup
                                                                        transform:currentTransform];
      [self addSublayer:groupLayer];
    }
  }
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.borderColor = debugModeOn ? [UIColor blueColor].CGColor : nil;
  self.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor : nil;
}

@end
