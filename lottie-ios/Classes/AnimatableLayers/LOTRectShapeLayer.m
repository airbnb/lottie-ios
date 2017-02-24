//
//  LOTRectShapeLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTRectShapeLayer.h"
#import "LOTPlatformCompat.h"
#import "CAAnimationGroup+LOTAnimatableGroup.h"
#import "LOTStrokeShapeLayer.h"
#import "LOTHelpers.h"

@interface LOTRoundRectLayer : LOTStrokeShapeLayer

@property (nonatomic) CGPoint rectPosition;
@property (nonatomic) CGPoint rectSize;
@property (nonatomic) CGFloat rectCornerRadius;

@end

@implementation LOTRoundRectLayer

@dynamic rectPosition;
@dynamic rectSize;
@dynamic rectCornerRadius;

-(id)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    if ([layer isKindOfClass:[LOTRoundRectLayer class]]) {
      self.rectSize = ((LOTRoundRectLayer *)layer).rectSize;
      self.rectPosition = ((LOTRoundRectLayer *)layer).rectPosition;
      self.rectCornerRadius = ((LOTRoundRectLayer *)layer).rectCornerRadius;
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
  LOTRoundRectLayer *presentationRect = (LOTRoundRectLayer *)self.presentationLayer;
  if (presentationRect == nil) {
    presentationRect = self;
  }
  CGFloat halfWidth = presentationRect.rectSize.x / 2;
  CGFloat halfHeight = presentationRect.rectSize.y / 2;
  
  CGRect rectFrame =  CGRectMake(presentationRect.rectPosition.x - halfWidth, presentationRect.rectPosition.y - halfHeight, presentationRect.rectSize.x, presentationRect.rectSize.y);
  
  // UIBezierPath Draws rects from the top left corner, After Effects draws them from the top right.
  // Switching to manual drawing.
  
  CGFloat radius = MIN(MIN(halfWidth, halfHeight), presentationRect.rectCornerRadius);
  UIBezierPath *path1 = [UIBezierPath new];
  UIBezierPath *path2 = [UIBezierPath new];
  
  CGPoint point =  CGPointMake(CGRectGetMaxX(rectFrame), CGRectGetMinY(rectFrame) + radius);
  [path1 moveToPoint:point];
  [path2 moveToPoint:point];
  
  point.y = CGRectGetMaxY(rectFrame) - radius;
  [path1 addLineToPoint:point];
  [path2 addLineToPoint:point];
  
  if (radius > 0) {
    point.x = point.x - radius;
    [path1 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(0) endAngle:LOT_DegreesToRadians(90) clockwise:YES];
    [path2 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(0) endAngle:LOT_DegreesToRadians(90) clockwise:YES];
  }
  
  point.x = CGRectGetMinX(rectFrame) + radius;
  point.y = CGRectGetMaxY(rectFrame);
  [path1 addLineToPoint:point];
  [path2 addLineToPoint:point];
  
  if (radius > 0) {
    point.y = point.y - radius;
    [path1 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(90) endAngle:LOT_DegreesToRadians(180) clockwise:YES];
    [path2 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(90) endAngle:LOT_DegreesToRadians(180) clockwise:YES];
  }
  
  point.x = CGRectGetMinX(rectFrame);
  point.y = CGRectGetMinY(rectFrame) + radius;
  [path1 addLineToPoint:point];
  [path2 addLineToPoint:point];
  
  if (radius > 0) {
    point.x = point.x + radius;
    [path1 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(180) endAngle:LOT_DegreesToRadians(270) clockwise:YES];
    [path2 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(180) endAngle:LOT_DegreesToRadians(270) clockwise:YES];
  }
  
  point.x = CGRectGetMaxX(rectFrame) - radius;
  point.y = CGRectGetMinY(rectFrame);
  [path1 addLineToPoint:point];
  [path2 addLineToPoint:point];
  
  if (radius > 0) {
    point.y = point.y + radius;
    [path1 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(270) endAngle:LOT_DegreesToRadians(360) clockwise:YES];
    [path2 addArcWithCenter:point radius:radius startAngle:LOT_DegreesToRadians(270) endAngle:LOT_DegreesToRadians(360) clockwise:YES];
  }
  [path1 closePath];
  [path2 closePath];
  
  [path1 appendPath:path2];

  self.path = path1.CGPath;
}

- (void)display {
  [self _setPath];
  [super display];
}

@end

@implementation LOTRectShapeLayer {
  LOTShapeTransform *_transform;
  LOTShapeStroke *_stroke;
  LOTShapeFill *_fill;
  LOTShapeRectangle *_rectangle;
  LOTShapeTrimPath *_trim;
  
  LOTRoundRectLayer *_fillLayer;
  LOTRoundRectLayer *_strokeLayer;
  
  CAAnimationGroup *_animation;
  CAAnimationGroup *_strokeAnimation;
  CAAnimationGroup *_fillAnimation;
}

- (instancetype)initWithRectShape:(LOTShapeRectangle *)rectShape
                             fill:(LOTShapeFill *)fill
                           stroke:(LOTShapeStroke *)stroke
                             trim:(LOTShapeTrimPath *)trim
                        transform:(LOTShapeTransform *)transform
                     withLayerDuration:(NSTimeInterval)duration {
  self = [super initWithLayerDuration:duration];
  if (self) {
    _rectangle = rectShape;
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
      _fillLayer = [LOTRoundRectLayer layer];
      _fillLayer.allowsEdgeAntialiasing = YES;
      _fillLayer.fillColor = _fill.color.initialColor.CGColor;
      _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
      _fillLayer.rectCornerRadius = rectShape.cornerRadius.initialValue.floatValue;
      _fillLayer.rectSize = rectShape.size.initialPoint;
      _fillLayer.rectPosition = rectShape.position.initialPoint;
      [self addSublayer:_fillLayer];
    }
    
    if (stroke) {
      _strokeLayer = [LOTRoundRectLayer layer];
      _strokeLayer.allowsEdgeAntialiasing = YES;
      _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
      _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
      _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
      _strokeLayer.fillColor = nil;
      _strokeLayer.backgroundColor = nil;
      _strokeLayer.lineDashPattern = _stroke.lineDashPattern;
      _strokeLayer.lineCap = _stroke.capType == LOTLineCapTypeRound ? kCALineCapRound : kCALineCapButt;
      _strokeLayer.rectCornerRadius = rectShape.cornerRadius.initialValue.floatValue;
      _strokeLayer.rectSize = rectShape.size.initialPoint;
      _strokeLayer.rectPosition = rectShape.position.initialPoint;
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
                                                                                      @"rectSize" : _rectangle.size,
                                                                                      @"rectPosition" : _rectangle.position,
                                                                                      @"rectCornerRadius" : _rectangle.cornerRadius}];
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
                                                                                           @"rectSize" : _rectangle.size,
                                                                                           @"rectPosition" : _rectangle.position,
                                                                                           @"rectCornerRadius" : _rectangle.cornerRadius}];
    [_fillLayer addAnimation:_fillAnimation forKey:@""];
  }
}

@end
