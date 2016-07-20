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
#import "CAAnimationGroup+LAAnimatableGroup.h"

@interface LAParentLayer : CALayer

- (instancetype)initWithParentModel:(LALayer *)parent compBounds:(CGRect)bounds;
- (void)startAnimation;

@end

@implementation LAParentLayer {
  LALayer *_parentModel;
  CAAnimationGroup *_animation;
}

- (instancetype)initWithParentModel:(LALayer *)parent compBounds:(CGRect)bounds {
  self = [super init];
  if (self) {
    self.bounds = bounds;
    _parentModel = parent;
    [self _setupLayerFromModel];
  }
  return self;
}

- (void)_setupLayerFromModel {
  self.position = _parentModel.position.initialPoint;
  self.anchorPoint = _parentModel.anchor.initialPoint;
  self.transform = _parentModel.scale.initialScale;
  self.sublayerTransform = CATransform3DMakeRotation(_parentModel.rotation.initialValue.floatValue, 0, 0, 1);
  [self _buildAnimations];
}

- (void)_buildAnimations {
  _animation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"position" : _parentModel.position,
                                                                                     @"anchorPoint" : _parentModel.anchor,
                                                                                     @"transform" : _parentModel.scale,
                                                                                     @"sublayerTransform.rotation" : _parentModel.rotation}];
}

- (void)startAnimation {
  if (_animation) {
    [self addAnimation:_animation forKey:@"lotteAnimation"];
  }
}

@end

@implementation LALayerView {
  NSArray<LAGroupLayerView *> *_shapeLayers;
  CALayer *_childContainerLayer;
  CALayer *_rotationLayer;
  CAAnimationGroup *_animation;
  NSArray<LAParentLayer *> *_parentLayers;
}

- (instancetype)initWithModel:(LALayer *)model inComposition:(LAComposition *)comp {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _layerModel = model;
    [self _setupViewFromModelInComposition:comp];
  }
  return self;
}

- (void)_setupViewFromModelInComposition:(LAComposition *)comp {
  _childContainerLayer = [CALayer new];
  // Setup Parents
  
  NSNumber *parentID = _layerModel.parentID;
  CALayer *currentChild = _childContainerLayer;
  NSMutableArray *parentLayers = [NSMutableArray array];
  if (parentID) {
    while (parentID != nil) {
      LALayer *parentModel = [comp layerModelForID:parentID];
      LAParentLayer *parentLayer = [[LAParentLayer alloc] initWithParentModel:parentModel compBounds:comp.compBounds];
      [parentLayer addSublayer:currentChild];
      [parentLayers addObject:parentLayer];
      currentChild = parentLayer;
      parentID = parentModel.parentID;
    }
  }
  if (parentLayers.count) {
    _parentLayers = parentLayers;
  }
  [self.layer addSublayer:currentChild];
  
  self.alpha = _layerModel.opacity.initialValue.floatValue;
  _childContainerLayer.position = _layerModel.position.initialPoint;
  _childContainerLayer.anchorPoint = _layerModel.anchor.initialPoint;
  _childContainerLayer.transform = _layerModel.scale.initialScale;
  _childContainerLayer.sublayerTransform = CATransform3DMakeRotation(_layerModel.rotation.initialValue.floatValue, 0, 0, 1);
  self.clipsToBounds = NO;
  
  NSArray *groupItems = _layerModel.shapes;
  NSArray *reversedItems = [[groupItems reverseObjectEnumerator] allObjects];
  LAShapeTransform *currentTransform = nil;
  
  NSMutableArray *shapeLayers = [NSMutableArray array];
  
  for (id item in reversedItems) {
    if ([item isKindOfClass:[LAShapeGroup class]]) {
      LAGroupLayerView *groupLayer = [[LAGroupLayerView alloc] initWithShapeGroup:(LAShapeGroup *)item transform:currentTransform];
      [_childContainerLayer addSublayer:groupLayer];
      [shapeLayers addObject:groupLayer];
    } else if ([item isKindOfClass:[LAShapeTransform class]]) {
      currentTransform = (LAShapeTransform *)item;
    }
  }
  
  _shapeLayers = shapeLayers;
  [self _buildAnimations];
}

- (void)_buildAnimations {
  _animation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : _layerModel.opacity,
                                                                                     @"position" : _layerModel.position,
                                                                                     @"anchorPoint" : _layerModel.anchor,
                                                                                     @"transform" : _layerModel.scale,
                                                                                     @"sublayerTransform.rotation" : _layerModel.rotation}];
}

- (void)startAnimation {
  if (_animation) {
    [_childContainerLayer addAnimation:_animation forKey:@"lotteAnimation"];
  }
  for (LAGroupLayerView *groupLayer in _shapeLayers) {
    [groupLayer startAnimation];
  }
  for (LAParentLayer *parent in _parentLayers) {
    [parent startAnimation];
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
  
  for (LAGroupLayerView *group in _shapeLayers) {
    group.debugModeOn = debugModeOn;
  }
}

@end
