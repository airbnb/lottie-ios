//
//  LOTGroupLayerView.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTGroupLayerView.h"
#import "LOTShapeLayerView.h"
#import "LOTRectShapeLayer.h"
#import "LOTEllipseShapeLayer.h"

#import "CAAnimationGroup+LOTAnimatableGroup.h"

@implementation LOTGroupLayerView {
  NSArray<LOTGroupLayerView *> *_groupLayers;
  NSArray<LOTShapeLayerView *> *_shapeLayers;
  CAAnimationGroup *_animation;
}

- (instancetype)initWithShapeGroup:(LOTShapeGroup *)shapeGroup
                         transform:(LOTShapeTransform *)previousTransform
                              fill:(LOTShapeFill *)previousFill
                            stroke:(LOTShapeStroke *)previousStroke
                          trimPath:(LOTShapeTrimPath *)previousTrimPath
                      withDuration:(NSTimeInterval)duration {
  self = [super initWithDuration:duration];
  if (self) {
    _shapeGroup = shapeGroup;
    _shapeTransform = previousTransform;
    [self _setupShapeGroupWithFill:previousFill stroke:previousStroke trimPath:previousTrimPath];
  }
  return self;
}

- (void)_setupShapeGroupWithFill:(LOTShapeFill *)previousFill
                          stroke:(LOTShapeStroke *)previousStroke
                        trimPath:(LOTShapeTrimPath *)previousTrimPath {
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
  
  LOTShapeFill *currentFill = previousFill;
  LOTShapeStroke *currentStroke = previousStroke;
  LOTShapeTransform *currentTransform;
  LOTShapeTrimPath *currentTrim = previousTrimPath;
  
  NSMutableArray *shapeLayers = [NSMutableArray array];
  NSMutableArray *groupLayers = [NSMutableArray array];
  
  for (id item in reversedItems) {
    if ([item isKindOfClass:[LOTShapeTransform class]]) {
      currentTransform = item;
    } else if ([item isKindOfClass:[LOTShapeStroke class]]) {
      currentStroke = item;
    } else if ([item isKindOfClass:[LOTShapeFill class]]) {
      currentFill = item;
    } else if ([item isKindOfClass:[LOTShapeTrimPath class]]) {
      currentTrim = item;
    } else if ([item isKindOfClass:[LOTShapePath class]]) {
      LOTShapePath *shapePath = (LOTShapePath *)item;
      LOTShapeLayerView *shapeLayer = [[LOTShapeLayerView alloc] initWithShape:shapePath
                                                                        fill:currentFill
                                                                      stroke:currentStroke
                                                                        trim:currentTrim
                                                                   transform:currentTransform
                                                                withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [self addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LOTShapeRectangle class]]) {
      LOTShapeRectangle *shapeRect = (LOTShapeRectangle *)item;
      LOTRectShapeLayer *shapeLayer = [[LOTRectShapeLayer alloc] initWithRectShape:shapeRect
                                                                              fill:currentFill
                                                                            stroke:currentStroke
                                                                              trim:currentTrim
                                                                         transform:currentTransform
                                                                      withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [self addSublayer:shapeLayer];
    }  else if ([item isKindOfClass:[LOTShapeCircle class]]) {
      LOTShapeCircle *shapeCircle = (LOTShapeCircle *)item;
      LOTEllipseShapeLayer *shapeLayer = [[LOTEllipseShapeLayer alloc] initWithEllipseShape:shapeCircle
                                                                                     fill:currentFill
                                                                                   stroke:currentStroke
                                                                                     trim:currentTrim
                                                                                transform:currentTransform
                                                                             withDuration:self.laAnimationDuration];
      [shapeLayers addObject:shapeLayer];
      [self addSublayer:shapeLayer];
    } else if ([item isKindOfClass:[LOTShapeGroup class]]) {
      LOTShapeGroup *shapeGroup = (LOTShapeGroup *)item;
      LOTGroupLayerView *groupLayer = [[LOTGroupLayerView alloc] initWithShapeGroup:shapeGroup
                                                                        transform:currentTransform
                                                                             fill:currentFill
                                                                           stroke:currentStroke
                                                                         trimPath:currentTrim
                                                                     withDuration:self.laAnimationDuration];
      [groupLayers addObject:groupLayer];
      [self addSublayer:groupLayer];
    }
  }
  _groupLayers = groupLayers;
  _shapeLayers = shapeLayers;
  
  [self _buildAnimation];
}

- (void)_buildAnimation {
  if (_shapeTransform) {
    _animation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : _shapeTransform.opacity,
                                                                                       @"position" : _shapeTransform.position,
                                                                                       @"anchorPoint" : _shapeTransform.anchor,
                                                                                       @"transform" : _shapeTransform.scale,
                                                                                       @"sublayerTransform.rotation" : _shapeTransform.rotation}];
    [self addAnimation:_animation forKey:@"LottieAnimation"];
  }
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.borderColor = debugModeOn ? [UIColor blueColor].CGColor : nil;
  self.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor : nil;
}

@end
