//
//  LOTEllipseShapeLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTEllipseShapeLayer.h"
#import "CAAnimationGroup+LOTAnimatableGroup.h"
#import "LOTStrokeShapeLayer.h"

const CGFloat kEllipseControlPointPercentage = 0.55228;

@interface LOTCircleShapeLayer : LOTStrokeShapeLayer

@property (nonatomic) CGPoint circlePosition;
@property (nonatomic) CGPoint circleSize;

@end

@implementation LOTCircleShapeLayer

@dynamic circleSize;
@dynamic circlePosition;

-(id)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    if ([layer isKindOfClass:[LOTCircleShapeLayer class]]) {
      self.circleSize = ((LOTCircleShapeLayer *)layer).circleSize;
      self.circlePosition = ((LOTCircleShapeLayer *)layer).circlePosition;
    }
  }
  return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  BOOL needsDisplay = [super needsDisplayForKey:key];
  
  if ([key isEqualToString:@"circlePosition"] || [key isEqualToString:@"circleSize"]) {
    needsDisplay = YES;
  }
  
  return needsDisplay;
}

-(id<CAAction>)actionForKey:(NSString *)event {
  if( [event isEqualToString:@"circlePosition"] || [event isEqualToString:@"circleSize"]) {
    CABasicAnimation *theAnimation = [CABasicAnimation
                                      animationWithKeyPath:event];
    theAnimation.fromValue = [[self presentationLayer] valueForKey:event];
    return theAnimation;
  }
  return [super actionForKey:event];
}

- (void)_setPath {
  LOTCircleShapeLayer *presentationCircle = (LOTCircleShapeLayer *)self.presentationLayer;
  if (presentationCircle == nil) {
    presentationCircle = self;
  }
  CGFloat halfWidth = presentationCircle.circleSize.x / 2;
  CGFloat halfHeight = presentationCircle.circleSize.y / 2;
  
  CGPoint circleQ1 = CGPointMake(0, -halfHeight);
  CGPoint circleQ2 = CGPointMake(halfWidth, 0);
  CGPoint circleQ3 = CGPointMake(0, halfHeight);
  CGPoint circleQ4 = CGPointMake(-halfWidth, 0);
  
  CGFloat cpW = halfWidth * kEllipseControlPointPercentage;
  CGFloat cpH = halfHeight * kEllipseControlPointPercentage;

  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:circleQ1];
  [path addCurveToPoint:circleQ2 controlPoint1:CGPointMake(circleQ1.x + cpW, circleQ1.y) controlPoint2:CGPointMake(circleQ2.x, circleQ2.y - cpH)];
  
  [path addCurveToPoint:circleQ3 controlPoint1:CGPointMake(circleQ2.x, circleQ2.y + cpH) controlPoint2:CGPointMake(circleQ3.x + cpW, circleQ3.y)];
  
  [path addCurveToPoint:circleQ4 controlPoint1:CGPointMake(circleQ3.x - cpW, circleQ3.y) controlPoint2:CGPointMake(circleQ4.x, circleQ4.y + cpH)];
  
  [path addCurveToPoint:circleQ1 controlPoint1:CGPointMake(circleQ4.x, circleQ4.y - cpH) controlPoint2:CGPointMake(circleQ1.x - cpW, circleQ1.y)];
  
  // Double path for trim offset.
  [path moveToPoint:circleQ1];
  [path addCurveToPoint:circleQ2 controlPoint1:CGPointMake(circleQ1.x + cpW, circleQ1.y) controlPoint2:CGPointMake(circleQ2.x, circleQ2.y - cpH)];
  
  [path addCurveToPoint:circleQ3 controlPoint1:CGPointMake(circleQ2.x, circleQ2.y + cpH) controlPoint2:CGPointMake(circleQ3.x + cpW, circleQ3.y)];
  
  [path addCurveToPoint:circleQ4 controlPoint1:CGPointMake(circleQ3.x - cpW, circleQ3.y) controlPoint2:CGPointMake(circleQ4.x, circleQ4.y + cpH)];
  
  [path addCurveToPoint:circleQ1 controlPoint1:CGPointMake(circleQ4.x, circleQ4.y - cpH) controlPoint2:CGPointMake(circleQ1.x - cpW, circleQ1.y)];
  
  //Move path(s)
  [path applyTransform:CGAffineTransformMakeTranslation(presentationCircle.circlePosition.x, presentationCircle.circlePosition.y)];
  
  self.path = path.CGPath;
}

- (void)display {
  [self _setPath];
  [super display];
}

@end

@implementation LOTEllipseShapeLayer {
  LOTShapeTransform *_transform;
  LOTShapeStroke *_stroke;
  LOTShapeFill *_fill;
  LOTShapeCircle *_circle;
  LOTShapeTrimPath *_trim;
  
  LOTCircleShapeLayer *_fillLayer;
  LOTCircleShapeLayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithEllipseShape:(LOTShapeCircle *)circleShape
                                fill:(LOTShapeFill *)fill
                              stroke:(LOTShapeStroke *)stroke
                                trim:(LOTShapeTrimPath *)trim
                           transform:(LOTShapeTransform *)transform
                        withLayerDuration:(NSTimeInterval)duration {
  self = [super initWithLayerDuration:duration];
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
      _fillLayer = [LOTCircleShapeLayer new];
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      _fillLayer.circlePosition = circleShape.position.initialPoint;
      _fillLayer.circleSize = circleShape.size.initialPoint;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [LOTCircleShapeLayer new];
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.fillColor = nil;
      _strokeLayer.backgroundColor = nil;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      _strokeLayer.lineCap = _stroke.capType == LOTLineCapTypeRound ? kCALineCapRound : kCALineCapButt;
      _strokeLayer.circlePosition = circleShape.position.initialPoint;
      _strokeLayer.circleSize = circleShape.size.initialPoint;
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
                                                                                      @"circlePosition" : _circle.position,
                                                                                      @"circleSize" : _circle.size}];
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
                                                                                           @"circlePosition" : _circle.position,
                                                                                           @"circleSize" : _circle.size}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
