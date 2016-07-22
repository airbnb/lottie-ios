//
//  LARectShapeLayer.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LARectShapeLayer.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

@implementation LARectShapeLayer {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapeRectangle *_rectangle;
  
  CALayer *_fillLayer;
  CALayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithRectShape:(LAShapeRectangle *)rectShape
                             fill:(LAShapeFill *)fill
                           stroke:(LAShapeStroke *)stroke
                        transform:(LAShapeTransform *)transform
                     withDuration:(NSTimeInterval)duration {
  self = [super initWithDuration:duration];
  if (self) {
    _rectangle = rectShape;
    _stroke = stroke;
    _fill = fill;
    _transform = transform;
    
    self.allowsEdgeAntialiasing = YES;
    self.frame = _transform.compBounds;
    self.anchorPoint = _transform.anchor.initialPoint;
    self.opacity = _transform.opacity.initialValue.floatValue;
    self.position = _transform.position.initialPoint;
    self.transform = _transform.scale.initialScale;
    self.sublayerTransform = CATransform3DMakeRotation(_transform.rotation.initialValue.floatValue, 0, 0, 1);
    
    _fillLayer = [CALayer layer];
    _fillLayer.allowsEdgeAntialiasing = YES;
    _fillLayer.bounds = rectShape.bounds.initialBounds;
    _fillLayer.position = rectShape.position.initialPoint;
    _fillLayer.cornerRadius = rectShape.cornerRadius.initialValue.floatValue;
    _fillLayer.backgroundColor = _fill.color.initialColor.CGColor;
    _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
    [self addSublayer:_fillLayer];
    
    _strokeLayer = [CALayer layer];
    _strokeLayer.allowsEdgeAntialiasing = YES;
    _strokeLayer.bounds = rectShape.bounds.initialBounds;
    _strokeLayer.position = rectShape.position.initialPoint;
    _strokeLayer.cornerRadius = rectShape.cornerRadius.initialValue.floatValue;
    _strokeLayer.borderColor = _stroke.color.initialColor.CGColor;
    _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
    _strokeLayer.borderWidth = _stroke.width.initialValue.floatValue;
    _strokeLayer.backgroundColor = nil;
    [self addSublayer:_strokeLayer];
    [self _buildAnimation];
    [self pause];
    
  }
  return self;
}

- (void)_buildAnimation {
  if (_transform) {
    _animation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : _transform.opacity,
                                                                                       @"position" : _transform.position,
                                                                                       @"anchorPoint" : _transform.anchor,
                                                                                       @"transform" : _transform.scale,
                                                                                       @"sublayerTransform.rotation" : _transform.rotation}];
    [self addAnimation:_animation forKey:@"LotteAnimation"];
  }
  
  if (_stroke) {
    _strokeAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"strokeColor" : _stroke.color,
                                                                                             @"opacity" : _stroke.opacity,
                                                                                             @"lineWidth" : _stroke.width,
                                                                                             @"bounds" : _rectangle.bounds,
                                                                                             @"position" : _rectangle.position,
                                                                                             @"cornerRadius" : _rectangle.cornerRadius}];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];

  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"backgroundColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"bounds" : _rectangle.bounds,
                                                                                           @"position" : _rectangle.position,
                                                                                           @"cornerRadius" : _rectangle.cornerRadius}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
