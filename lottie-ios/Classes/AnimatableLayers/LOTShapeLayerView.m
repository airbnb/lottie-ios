//
//  LOTShapeLayerView.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTShapeLayerView.h"
#import "CAAnimationGroup+LOTAnimatableGroup.h"
#import "LOTStrokeShapeLayer.h"

@implementation LOTShapeLayerView {
  LOTShapeTransform *_transform;
  LOTShapeStroke *_stroke;
  LOTShapeFill *_fill;
  LOTShapePath *_path;
  LOTShapeTrimPath *_trim;
  
  CAShapeLayer *_fillLayer;
  LOTStrokeShapeLayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithShape:(LOTShapePath *)shape
                         fill:(LOTShapeFill *)fill
                       stroke:(LOTShapeStroke *)stroke
                         trim:(LOTShapeTrimPath *)trim
                    transform:(LOTShapeTransform *)transform
                 withLayerDuration:(NSTimeInterval)duration {
  self = [super initWithLayerDuration:duration];
  if (self) {
    _path = shape;
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
      _fillLayer = [CAShapeLayer layer];
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.path = _path.shapePath.initialShape.CGPath;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [LOTStrokeShapeLayer layer];
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.path = _path.shapePath.initialShape.CGPath;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      _strokeLayer.lineCap = _stroke.capType == LOTLineCapTypeRound ? kCALineCapRound : kCALineCapButt;
      switch (_stroke.joinType) {
        case LOTLineJoinTypeBevel:
          _strokeLayer.lineJoin = kCALineJoinBevel;
          break;
        case LOTLineJoinTypeMiter:
          _strokeLayer.lineJoin = kCALineJoinMiter;
          break;
        case LOTLineJoinTypeRound:
          _strokeLayer.lineJoin = kCALineJoinRound;
          break;
        default:
          break;
      }
      if (trim) {
        _strokeLayer.trimStart = _trim.start.initialValue.floatValue;
        _strokeLayer.trimEnd = _trim.end.initialValue.floatValue;
        _strokeLayer.trimOffset = _trim.offset.initialValue.floatValue;
      }
      _strokeLayer.fillColor = nil;
      [self addSublayer:_strokeLayer];
    }

    
    [self _buildAnimation];
  }
  return self;
}

- (void)_buildAnimation {
  if (_transform) {
    _animation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:@{@"opacity" : _transform.opacity,
                                                                                       @"position" : _transform.position,
                                                                                       @"anchorPoint" : _transform.anchor,
                                                                                       @"transform" : _transform.scale,
                                                                                       @"sublayerTransform.rotation" : _transform.rotation}];
    [self addAnimation:_animation forKey:@"LottieAnimation"];
  }
  
  if (_stroke) {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{@"strokeColor" : _stroke.color,
                                                                                      @"opacity" : _stroke.opacity,
                                                                                      @"lineWidth" : _stroke.width,
                                                                                      @"path" : _path.shapePath}];
    if (_trim) {
      properties[@"trimStart"] = _trim.start;
      properties[@"trimEnd"] = _trim.end;
      properties[@"trimOffset"] = _trim.offset;
    }
    _strokeAnimation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:properties];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];
  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup LOT_animationGroupForAnimatablePropertiesWithKeyPaths:@{@"fillColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"path" : _path.shapePath}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
