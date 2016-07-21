//
//  LAGroupLayerView.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAGroupLayerView.h"
#import "LAShapeLayerView.h"
#import "LARectShapeLayer.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

@implementation LAGroupLayerView {
  NSArray<LAGroupLayerView *> *_groupLayers;
  NSArray<LAShapeLayerView *> *_shapeLayers;
  CAAnimationGroup *_animation;
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
    self.transform = _shapeTransform.scale.initialScale;
    self.sublayerTransform = CATransform3DMakeRotation(_shapeTransform.rotation.initialValue.floatValue, 0, 0, 1);
  }
  
  NSArray *groupItems = _shapeGroup.items;
  NSArray *reversedItems = [[groupItems reverseObjectEnumerator] allObjects];
  
  LAShapeFill *currentFill;
  LAShapeStroke *currentStroke;
  LAShapeTransform *currentTransform;
  
  NSMutableArray *shapeLayers = [NSMutableArray array];
  NSMutableArray *groupLayers = [NSMutableArray array];
  
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
      [shapeLayers addObject:shapeLayer];
      [self addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LAShapeRectangle class]]) {
      LAShapeRectangle *shapeRect = (LAShapeRectangle *)item;
      LARectShapeLayer *shapeLayer = [[LARectShapeLayer alloc] initWithRectShape:shapeRect
                                                                            fill:currentFill
                                                                          stroke:currentStroke
                                                                       transform:currentTransform];
      [shapeLayers addObject:shapeLayer];
      [self addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LAShapeGroup class]]) {
      LAShapeGroup *shapeGroup = (LAShapeGroup *)item;
      LAGroupLayerView *groupLayer = [[LAGroupLayerView alloc] initWithShapeGroup:shapeGroup
                                                                        transform:currentTransform];
      [groupLayers addObject:groupLayer];
      [self addSublayer:groupLayer];
    }
  }
  _groupLayers = groupLayers;
  _shapeLayers = shapeLayers;
  
  NSMutableArray *childLayers = [NSMutableArray array];
  [childLayers addObjectsFromArray:groupLayers];
  [childLayers addObjectsFromArray:shapeLayers];
  self.childLayers = childLayers;
  
  [self _buildAnimation];
  [self pause];
}

- (void)_buildAnimation {
  if (_shapeTransform) {
    _animation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : _shapeTransform.opacity,
                                                                                       @"position" : _shapeTransform.position,
                                                                                       @"anchorPoint" : _shapeTransform.anchor,
                                                                                       @"transform" : _shapeTransform.scale,
                                                                                       @"sublayerTransform.rotation" : _shapeTransform.rotation}];
    [self addAnimation:_animation forKey:@"lotteAnimation"];
  }
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.borderColor = debugModeOn ? [UIColor blueColor].CGColor : nil;
  self.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor : nil;
}

@end
