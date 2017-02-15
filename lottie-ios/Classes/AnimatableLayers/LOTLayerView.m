//
//  LOTLayerView.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTLayerView.h"
#import "LOTShapeLayerView.h"
#import "LOTRectShapeLayer.h"
#import "LOTEllipseShapeLayer.h"
#import "LOTGroupLayerView.h"
#import "CAAnimationGroup+LOTAnimatableGroup.h"
#import "LOTMaskLayer.h"
#import "CGGeometry+LOTAdditions.h"

@interface LOTParentLayer : LOTAnimatableLayer

- (instancetype)initWithParentModel:(LOTLayer *)parent inComposition:(LOTComposition *)comp;

@end

@implementation LOTParentLayer {
  LOTLayer *_parentModel;
  CAAnimationGroup *_animation;
}

- (instancetype)initWithParentModel:(LOTLayer *)parent inComposition:(LOTComposition *)comp {
  self = [super initWithDuration:comp.timeDuration];
  if (self) {
    self.bounds = parent.compBounds;
    _parentModel = parent;
    [self _setupLayerFromModel];
  }
  return self;
}

- (void)_setupLayerFromModel {
  if (_parentModel.position) {
    self.position = _parentModel.position.initialPoint;
  } else {
    CGPoint initial = CGPointZero;
    if (_parentModel.positionX) {
      initial.x = _parentModel.positionX.initialValue.floatValue;
    }
    if (_parentModel.positionY) {
      initial.y = _parentModel.positionY.initialValue.floatValue;
    }
    self.position = initial;
  }
  
  self.anchorPoint = _parentModel.anchor.initialPoint;
  self.transform = _parentModel.scale.initialScale;
  self.sublayerTransform = CATransform3DMakeRotation(_parentModel.rotation.initialValue.floatValue, 0, 0, 1);
  [self _buildAnimations];
}

- (void)_buildAnimations {
  NSMutableDictionary *keypaths = [NSMutableDictionary dictionary];
  if (_parentModel.position) {
    [keypaths setValue:_parentModel.position forKey:@"position"];
  }
  if (_parentModel.anchor) {
    [keypaths setValue:_parentModel.anchor forKey:@"anchorPoint"];
  }
  if (_parentModel.scale) {
    [keypaths setValue:_parentModel.scale forKey:@"transform"];
  }
  if (_parentModel.rotation) {
    [keypaths setValue:_parentModel.rotation forKey:@"sublayerTransform.rotation"];
  }
  if (_parentModel.positionX) {
    [keypaths setValue:_parentModel.positionX forKey:@"position.x"];
  }
  if (_parentModel.positionY) {
    [keypaths setValue:_parentModel.positionY forKey:@"position.y"];
  }

  _animation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:keypaths];
  [self addAnimation:_animation forKey:@"LottieAnimation"];
}

@end

@implementation LOTLayerView {
  NSArray<LOTGroupLayerView *> *_shapeLayers;
  CALayer *_childContainerLayer;
  CALayer *_rotationLayer;
  CAAnimationGroup *_animation;
  CAKeyframeAnimation *_inOutAnimation;
  NSArray<LOTParentLayer *> *_parentLayers;
  LOTComposition *_composition;
  LOTMaskLayer *_maskLayer;
}

- (instancetype)initWithModel:(LOTLayer *)model inComposition:(LOTComposition *)comp {
  self = [super initWithDuration:comp.timeDuration];
  if (self) {
    _layerModel = model;
    _composition = comp;
    [self _setupViewFromModel];
  }
  return self;
}

- (void)_setupViewFromModel {
  self.backgroundColor = nil;
  self.bounds = _composition.compBounds;
  self.anchorPoint = CGPointZero;
  
  _childContainerLayer = [CALayer new];
  _childContainerLayer.bounds = self.bounds;
  _childContainerLayer.backgroundColor = _layerModel.solidColor.CGColor;
  
  if (_layerModel.layerType == LOTLayerTypeSolid) {
    _childContainerLayer.bounds = CGRectMake(0, 0, _layerModel.solidWidth.floatValue, _layerModel.solidHeight.floatValue);
    _childContainerLayer.backgroundColor = nil;
    _childContainerLayer.masksToBounds = NO;

    CALayer *solid = [CALayer new];
    solid.backgroundColor = _layerModel.solidColor.CGColor;
    solid.frame = _childContainerLayer.bounds;
    solid.masksToBounds = YES;
    [_childContainerLayer addSublayer:solid];
  }
  
  NSNumber *parentID = _layerModel.parentID;
  CALayer *currentChild = _childContainerLayer;
  NSMutableArray *parentLayers = [NSMutableArray array];
  if (parentID) {
    while (parentID != nil) {
      LOTLayer *parentModel = [_composition layerModelForID:parentID];
      LOTParentLayer *parentLayer = [[LOTParentLayer alloc] initWithParentModel:parentModel inComposition:_composition];
      [parentLayer addSublayer:currentChild];
      [parentLayers addObject:parentLayer];
      currentChild = parentLayer;
      parentID = parentModel.parentID;
    }
  }
  if (parentLayers.count) {
    _parentLayers = parentLayers;
  }
  [self addSublayer:currentChild];
  
  _childContainerLayer.opacity = _layerModel.opacity.initialValue.floatValue;
  
  if (_layerModel.position) {
    _childContainerLayer.position = _layerModel.position.initialPoint;
  } else {
    CGPoint initial = CGPointZero;
    if (_layerModel.positionX) {
      initial.x = _layerModel.positionX.initialValue.floatValue;
    }
    if (_layerModel.positionY) {
      initial.y = _layerModel.positionY.initialValue.floatValue;
    }
    _childContainerLayer.position = initial;
  }
  _childContainerLayer.anchorPoint = _layerModel.anchor.initialPoint;
  _childContainerLayer.transform = _layerModel.scale.initialScale;
  _childContainerLayer.sublayerTransform = CATransform3DMakeRotation(_layerModel.rotation.initialValue.floatValue, 0, 0, 1);
  self.hidden = _layerModel.hasInAnimation;
  
  NSArray *groupItems = _layerModel.shapes;
  NSArray *reversedItems = [[groupItems reverseObjectEnumerator] allObjects];
  LOTShapeTransform *currentTransform = [LOTShapeTransform transformIdentityWithCompBounds:_composition.compBounds];
  LOTShapeTrimPath *currentTrimPath = nil;
  LOTShapeFill *currentFill = nil;
  LOTShapeStroke *currentStroke = nil;
  
  NSMutableArray *shapeLayers = [NSMutableArray array];
  
  for (id item in reversedItems) {
    if ([item isKindOfClass:[LOTShapeGroup class]]) {
      LOTGroupLayerView *groupLayer = [[LOTGroupLayerView alloc] initWithShapeGroup:(LOTShapeGroup *)item
                                                                        transform:currentTransform
                                                                             fill:currentFill
                                                                           stroke:currentStroke
                                                                         trimPath:currentTrimPath
                                                                     withDuration:self.laAnimationDuration];
      [_childContainerLayer addSublayer:groupLayer];
      [shapeLayers addObject:groupLayer];
    } else if ([item isKindOfClass:[LOTShapePath class]]) {
      LOTShapePath *shapePath = (LOTShapePath *)item;
      LOTShapeLayerView *shapeLayer = [[LOTShapeLayerView alloc] initWithShape:shapePath
                                                                        fill:currentFill
                                                                      stroke:currentStroke
                                                                        trim:currentTrimPath
                                                                   transform:currentTransform
                                                                withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [_childContainerLayer addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LOTShapeRectangle class]]) {
      LOTShapeRectangle *shapeRect = (LOTShapeRectangle *)item;
      LOTRectShapeLayer *shapeLayer = [[LOTRectShapeLayer alloc] initWithRectShape:shapeRect
                                                                              fill:currentFill
                                                                            stroke:currentStroke
                                                                              trim:currentTrimPath
                                                                         transform:currentTransform
                                                                    withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [_childContainerLayer addSublayer:shapeLayer];
    }  else if ([item isKindOfClass:[LOTShapeCircle class]]) {
      LOTShapeCircle *shapeCircle = (LOTShapeCircle *)item;
      LOTEllipseShapeLayer *shapeLayer = [[LOTEllipseShapeLayer alloc] initWithEllipseShape:shapeCircle
                                                                                     fill:currentFill
                                                                                   stroke:currentStroke
                                                                                     trim:currentTrimPath
                                                                                transform:currentTransform
                                                                             withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [_childContainerLayer addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LOTShapeTransform class]]) {
      currentTransform = (LOTShapeTransform *)item;
    } else if ([item isKindOfClass:[LOTShapeFill class]]) {
      currentFill = (LOTShapeFill *)item;
    } else if ([item isKindOfClass:[LOTShapeTrimPath class]]) {
      currentTrimPath = (LOTShapeTrimPath *)item;
    } else if ([item isKindOfClass:[LOTShapeStroke class]]) {
      currentStroke = (LOTShapeStroke *)item;
    }
  }
  
  _shapeLayers = shapeLayers;
  
  if (_layerModel.masks) {
    _maskLayer = [[LOTMaskLayer alloc] initWithMasks:_layerModel.masks inComposition:_composition];
    _childContainerLayer.mask = _maskLayer;
  }
  
  NSMutableArray *childLayers = [NSMutableArray array];
  [childLayers addObjectsFromArray:_parentLayers];
  [childLayers addObjectsFromArray:_shapeLayers];
  if (_maskLayer) {
    [childLayers addObject:_maskLayer];
  }

  [self _buildAnimations];
}

- (void)_buildAnimations {
  NSMutableDictionary *keypaths = [NSMutableDictionary dictionary];
  if (_layerModel.opacity) {
    [keypaths setValue:_layerModel.opacity forKey:@"opacity"];
  }
  if (_layerModel.position) {
    [keypaths setValue:_layerModel.position forKey:@"position"];
  }
  if (_layerModel.anchor) {
    [keypaths setValue:_layerModel.anchor forKey:@"anchorPoint"];
  }
  if (_layerModel.scale) {
    [keypaths setValue:_layerModel.scale forKey:@"transform"];
  }
  if (_layerModel.rotation) {
    [keypaths setValue:_layerModel.rotation forKey:@"sublayerTransform.rotation"];
  }
  if (_layerModel.positionX) {
    [keypaths setValue:_layerModel.positionX forKey:@"position.x"];
  }
  if (_layerModel.positionY) {
    [keypaths setValue:_layerModel.positionY forKey:@"position.y"];
  }
  
  
  _animation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:keypaths];
  
  if (_animation) {
    [_childContainerLayer addAnimation:_animation forKey:@"LottieAnimation"];
  }
  
  if (_layerModel.hasInOutAnimation) {
    CAKeyframeAnimation *inOutAnimation = [CAKeyframeAnimation animationWithKeyPath:@"hidden"];
    inOutAnimation.keyTimes = _layerModel.inOutKeyTimes;
    inOutAnimation.values = _layerModel.inOutKeyframes;
    inOutAnimation.duration = _layerModel.compDuration;
    inOutAnimation.calculationMode = kCAAnimationDiscrete;
    inOutAnimation.fillMode = kCAFillModeForwards;
    inOutAnimation.removedOnCompletion = NO;

    _inOutAnimation = inOutAnimation;
    _inOutAnimation.duration = self.laAnimationDuration;
    [self addAnimation:_inOutAnimation forKey:@""];
  }
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.borderColor = debugModeOn ? [UIColor redColor].CGColor : nil;
  self.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor blueColor] colorWithAlphaComponent:0.2].CGColor : [UIColor clearColor].CGColor;
  
  for (LOTGroupLayerView *group in _shapeLayers) {
    group.debugModeOn = debugModeOn;
  }
}

@end
