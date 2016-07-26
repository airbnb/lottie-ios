//
//  LAEllipseShapeLayer.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAEllipseShapeLayer.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

@implementation LAEllipseShapeLayer {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapeCircle *_circle;
  LAShapeTrimPath *_trim;
  
  CAShapeLayer *_fillLayer;
  CAShapeLayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithEllipseShape:(LAShapeCircle *)circleShape
                                fill:(LAShapeFill *)fill
                              stroke:(LAShapeStroke *)stroke
                                trim:(LAShapeTrimPath *)trim
                           transform:(LAShapeTransform *)transform
                        withDuration:(NSTimeInterval)duration {
  self = [super initWithDuration:duration];
  if (self) {
    _circle = circleShape;
    _stroke = stroke;
    _fill = fill;
    _transform = transform;
    _trim = trim;
    
    self.allowsEdgeAntialiasing = YES;
    self.frame = _transform.compBounds;
    self.anchorPoint = _transform.anchor.initialPoint;
    self.opacity = _transform.opacity.initialValue.floatValue;
    self.position = _transform.position.initialPoint;
    self.transform = _transform.scale.initialScale;
    self.sublayerTransform = CATransform3DMakeRotation(_transform.rotation.initialValue.floatValue, 0, 0, 1);
    
    if (fill) {
      _fillLayer = [CAShapeLayer new];
      _fillLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-50, -50, 100, 100)].CGPath;
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.position = circleShape.position.initialPoint;
      _fillLayer.transform = circleShape.scale.initialScale;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [CAShapeLayer new];
      _strokeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-50, -50, 100, 100)].CGPath;
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.position = circleShape.position.initialPoint;
      _strokeLayer.transform = circleShape.scale.initialScale;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.fillColor = nil;
      _strokeLayer.backgroundColor = nil;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      if (trim) {
        _strokeLayer.strokeStart = _trim.start.initialValue.floatValue;
        _strokeLayer.strokeEnd = _trim.end.initialValue.floatValue;
      }
      [self addSublayer:_strokeLayer];
    }
    self.animationSublayers = [NSArray arrayWithArray:self.sublayers];
    
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
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{@"strokeColor" : _stroke.color,
                                                                                      @"opacity" : _stroke.opacity,
                                                                                      @"lineWidth" : _stroke.width,
                                                                                      @"position" : _circle.position,
                                                                                      @"transform" : _circle.scale}];
    if (_trim) {
      properties[@"strokeStart"] = _trim.start;
      properties[@"strokeEnd"] = _trim.end;
    }
    _strokeAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:properties];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];
    
  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"backgroundColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"position" : _circle.position,
                                                                                           @"transform" : _circle.scale}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
