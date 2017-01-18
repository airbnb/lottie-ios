//
//  LARectShapeLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LARectShapeLayer.h"
#import "CAAnimationGroup+LAAnimatableGroup.h"

@interface LARoundRectLayer : CAShapeLayer

@property (nonatomic) CGPoint rectPosition;
@property (nonatomic) CGPoint rectSize;
@property (nonatomic) CGFloat rectCornerRadius;

@end

@implementation LARoundRectLayer

@dynamic rectPosition;
@dynamic rectSize;
@dynamic rectCornerRadius;

-(id)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    if ([layer isKindOfClass:[LARoundRectLayer class]]) {
      self.rectSize = ((LARoundRectLayer *)layer).rectSize;
      self.rectPosition = ((LARoundRectLayer *)layer).rectPosition;
      self.rectCornerRadius = ((LARoundRectLayer *)layer).rectCornerRadius;
    }
  }
  return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  BOOL needsDisplay = [super needsDisplayForKey:key];
  
  if ([key isEqualToString:@"rectSize"] || [key isEqualToString:@"rectPosition"] || [key isEqualToString:@"rectCornerRadius"]) {
    needsDisplay = YES;
  }
  
  return needsDisplay;
}

-(id<CAAction>)actionForKey:(NSString *)event {
  if([event isEqualToString:@"rectSize"] || [event isEqualToString:@"rectPosition"] || [event isEqualToString:@"rectCornerRadius"]) {
    CABasicAnimation *theAnimation = [CABasicAnimation
                                      animationWithKeyPath:event];
    theAnimation.fromValue = [[self presentationLayer] valueForKey:event];
    return theAnimation;
  }
  return [super actionForKey:event];
}

- (void)_setPath {
  LARoundRectLayer *presentationRect = (LARoundRectLayer *)self.presentationLayer;
  if (presentationRect == nil) {
    presentationRect = self;
  }
  CGFloat halfWidth = presentationRect.rectSize.x / 2;
  CGFloat halfHeight = presentationRect.rectSize.y / 2;
  
  CGRect rectFrame =  CGRectMake(presentationRect.rectPosition.x - halfWidth, presentationRect.rectPosition.y - halfHeight, presentationRect.rectSize.x, presentationRect.rectSize.y);
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rectFrame cornerRadius:presentationRect.rectCornerRadius];
  [path closePath];
  self.path = path.CGPath;
}

- (void)display {
  [self _setPath];
}

@end

@implementation LARectShapeLayer {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapeRectangle *_rectangle;
  
  LARoundRectLayer *_fillLayer;
  LARoundRectLayer *_strokeLayer;
  
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
    
    if (fill) {
      _fillLayer = [LARoundRectLayer layer];
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      _fillLayer.rectCornerRadius = rectShape.cornerRadius.initialValue.floatValue;
      _fillLayer.rectSize = rectShape.size.initialPoint;
      _fillLayer.rectPosition = rectShape.position.initialPoint;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [LARoundRectLayer layer];
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.fillColor = nil;
      _strokeLayer.backgroundColor = nil;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      _strokeLayer.lineCap = _stroke.capType == LALineCapTypeRound ? kCALineCapRound : kCALineCapButt;
      _strokeLayer.rectCornerRadius = rectShape.cornerRadius.initialValue.floatValue;
      _strokeLayer.rectSize = rectShape.size.initialPoint;
      _strokeLayer.rectPosition = rectShape.position.initialPoint;
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
//      if (trim) {
//        _strokeLayer.strokeStart = _trim.start.initialValue.floatValue;
//        _strokeLayer.strokeEnd = _trim.end.initialValue.floatValue;
//      }
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
    _strokeAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"strokeColor" : _stroke.color,
                                                                                             @"opacity" : _stroke.opacity,
                                                                                             @"lineWidth" : _stroke.width,
                                                                                             @"rectSize" : _rectangle.size,
                                                                                             @"rectPosition" : _rectangle.position,
                                                                                             @"rectCornerRadius" : _rectangle.cornerRadius}];
    [_strokeLayer addAnimation:_strokeAnimation forKey:@""];

  }
  
  if (_fill) {
    _fillAnimation = [CAAnimationGroup animationGroupForAnimatablePropertiesWithKeyPaths:@{@"fillColor" : _fill.color,
                                                                                           @"opacity" : _fill.opacity,
                                                                                           @"rectSize" : _rectangle.size,
                                                                                           @"rectPosition" : _rectangle.position,
                                                                                           @"rectCornerRadius" : _rectangle.cornerRadius}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
