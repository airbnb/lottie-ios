//
//  LAEllipseShapeLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAEllipseShapeLayer.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

const CGFloat kEllipseControlPointPercentage = 0.55228;

@interface LACircleShapeLayer : CAShapeLayer

@property (nonatomic) CGPoint circlePosition;
@property (nonatomic) CGPoint circleSize;

@end

@implementation LACircleShapeLayer

@dynamic circleSize;
@dynamic circlePosition;

-(id)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    if ([layer isKindOfClass:[LACircleShapeLayer class]]) {
      self.circleSize = ((LACircleShapeLayer *)layer).circleSize;
      self.circlePosition = ((LACircleShapeLayer *)layer).circlePosition;
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
  LACircleShapeLayer *presentationCircle = (LACircleShapeLayer *)self.presentationLayer;
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
  [path applyTransform:CGAffineTransformMakeTranslation(presentationCircle.circlePosition.x, presentationCircle.circlePosition.y)];
  self.path = path.CGPath;
}

- (void)display {
  [self _setPath];
}

@end

@implementation LAEllipseShapeLayer {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapeCircle *_circle;
  LAShapeTrimPath *_trim;
  
  LACircleShapeLayer *_fillLayer;
  LACircleShapeLayer *_strokeLayer;
  
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
      _fillLayer = [LACircleShapeLayer new];
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      _fillLayer.circlePosition = circleShape.position.initialPoint;
      _fillLayer.circleSize = circleShape.size.initialPoint;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [LACircleShapeLayer new];
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.fillColor = nil;
      _strokeLayer.backgroundColor = nil;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      _strokeLayer.lineCap = _stroke.capType == LALineCapTypeRound ? kCALineCapRound : kCALineCapButt;
      _strokeLayer.circlePosition = circleShape.position.initialPoint;
      _strokeLayer.circleSize = circleShape.size.initialPoint;
      switch (_stroke.joinType) {
        case LALineJoinTypeBevel:
          _strokeLayer.lineJoin = kCALineJoinBevel;
          break;
        case LALineJoinTypeMiter:
          _strokeLayer.lineJoin = kCALineJoinMiter;
          break;
        case LALineJoinTypeRound:
          _strokeLayer.lineJoin = kCALineJoinRound;
          break;
        default:
          break;
      }
      if (trim) {
        _strokeLayer.strokeStart = _trim.start.initialValue.floatValue;
        _strokeLayer.strokeEnd = _trim.end.initialValue.floatValue;
      }
      [self addSublayer:_strokeLayer];
    }
    
    [self _buildAnimation];
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
    [self addAnimation:_animation forKey:@"LottieAnimation"];
  }
  
  if (_stroke) {
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{@"strokeColor" : _stroke.color,
                                                                                      @"opacity" : _stroke.opacity,
                                                                                      @"lineWidth" : _stroke.width,
                                                                                      @"circlePosition" : _circle.position,
                                                                                      @"circleSize" : _circle.size}];
    if (_trim) {
      properties[@"strokeStart"] = _trim.start;
      properties[@"strokeEnd"] = _trim.end;
    }
    _strokeAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:properties];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];
    
  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"fillColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"circlePosition" : _circle.position,
                                                                                           @"circleSize" : _circle.size}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
