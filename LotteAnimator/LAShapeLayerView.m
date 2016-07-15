//
//  LAShapeLayerView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAShapeLayerView.h"

@implementation LAShapeLayerView {
  LAShapeTransform *_transform;
  LAShapeStroke *_stroke;
  LAShapeFill *_fill;
  LAShapePath *_path;
  
  CAShapeLayer *_fillLayer;
  CAShapeLayer *_strokeLayer;
}

- (instancetype)initWithShape:(LAShapePath *)shape
                         fill:(LAShapeFill *)fill
                       stroke:(LAShapeStroke *)stroke
                    transform:(LAShapeTransform *)transform {
  self = [super init];
  if (self) {
    _path = shape;
    _stroke = stroke;
    _fill = fill;
    _transform = transform;
    
    self.frame = _transform.compBounds;
    self.anchorPoint = _transform.anchor.initialPoint;
    self.opacity = _transform.opacity.initialValue.floatValue;
    self.position = _transform.position.initialPoint;
    
    _fillLayer = [CAShapeLayer layer];
    _fillLayer.path = _path.shapePath.initialShape.CGPath;
    _fillLayer.fillColor = _fill.color.initialColor.CGColor;
    _fillLayer.opacity = _fill.opacity.initialValue.floatValue;
    [self addSublayer:_fillLayer];
    
    _strokeLayer = [CAShapeLayer layer];
    _strokeLayer.path = _path.shapePath.initialShape.CGPath;
    _strokeLayer.strokeColor = _stroke.color.initialColor.CGColor;
    _strokeLayer.opacity = _stroke.opacity.initialValue.floatValue;
    _strokeLayer.lineWidth = _stroke.width.initialValue.floatValue;
    _strokeLayer.fillColor = nil;
    [self addSublayer:_strokeLayer];
    
    
  }
  return self;
}

@end
