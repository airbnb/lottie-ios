//
//  LAShapeLayerView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAShapeLayerView.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

@implementation LAShapeLayerView {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapePath *_path;
  
  CAShapeLayer *_fillLayer;
  CAShapeLayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithShape:(LAShapePath *)shape
                         fill:(LAShapeFill *)fill
                       stroke:(LAShapeStroke *)stroke
                    transform:(LAShapeTransform *)transform
                 withDuration:(NSTimeInterval)duration {
  self = [super initWithDuration:duration];
  if (self) {
    _path = shape;
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
    
    _fillLayer = [CAShapeLayer layer];
    _fillLayer.allowsEdgeAntialiasing = YES;
    _fillLayer.path = _path.shapePath.initialShape.CGPath;
    _fillLayer.fillColor = _fill.color.initialColor.CGColor;
    _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
    [self addSublayer:_fillLayer];
    
    _strokeLayer = [CAShapeLayer layer];
    _strokeLayer.allowsEdgeAntialiasing = YES;
    _strokeLayer.path = _path.shapePath.initialShape.CGPath;
    _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
    _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
    _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
    _strokeLayer.fillColor = nil;
    self.animationSublayers = @[_fillLayer, _strokeLayer];
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
                                                                                             @"path" : _path.shapePath}];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];
  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"fillColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"path" : _path.shapePath}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
