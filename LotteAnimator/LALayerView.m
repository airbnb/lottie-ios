//
//  LALayerView.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LALayerView.h"

@implementation LALayerView

- (instancetype)initWithModel:(LALayer *)model {
  self = [super initWithFrame:model.frameRect];
  if (self) {
    self.backgroundColor = model.bgColor;
    self.layer.anchorPoint = model.anchorPoint;
    self.frame = model.frameRect;
    self.transform = model.transform;
    self.alpha = model.alpha;
    _layerModel = model;
    if (model.masks) {
      self.clipsToBounds = NO;
      LAMask *maskModel = model.masks.firstObject;
      UIBezierPath *myClippingPath = [maskModel.maskPath bezierPath:maskModel.isClosed];
      
      CAShapeLayer *mask = [CAShapeLayer layer];
      mask.path = myClippingPath.CGPath;

      self.layer.mask = mask;
    }
    
    if (model.shapes) {
      self.clipsToBounds = NO;
      for (LAShape *shape in model.shapes) {
        // Get Path
        LAShapePath *path = shape.paths.count ? shape.paths.firstObject : nil;
        
        // Get Stroke
        LAShapeStroke *stroke = shape.strokes.count ? shape.strokes.firstObject : nil;
        
        //Get Fill
        LAShapeFill *fill = shape.fills.count ? shape.fills.firstObject : nil;
        
        //Get Transform
        LAShapeTransform *transform = shape.transforms.count ? shape.transforms.firstObject : nil;
        
        if (!path) {
          continue;
        }
        UIBezierPath *shapePath = [path.shapePath bezierPath:path.isClosed];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = shapePath.CGPath;
        
        if (stroke) {
          shapeLayer.strokeColor = stroke.color.CGColor;
          shapeLayer.lineWidth = stroke.width.floatValue;
        }
        
        if (fill) {
          shapeLayer.fillColor = fill.color.CGColor;
          shapeLayer.opacity = fill.alpha;
        }
        
        if (transform) {
//          shapeLayer.anchorPoint = transform.anchorPoint;
//          shapeLayer.position =
//          shapeLayer.transform = CATransform3DMakeAffineTransform(transform.transform);
        }
        [self.layer addSublayer:shapeLayer];
      }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_viewtapped)];
    [self addGestureRecognizer:tapGesture];
  }
  return self;
}

- (void)_viewtapped {
  NSLog(@"%@", self.layerModel);
}

- (void)setDebugModeOn:(BOOL)debugModeOn {
  _debugModeOn = debugModeOn;
  self.layer.borderColor = debugModeOn ? [UIColor redColor].CGColor : nil;
  self.layer.borderWidth = debugModeOn ? 2 : 0;
  self.backgroundColor = debugModeOn ? [[UIColor blueColor] colorWithAlphaComponent:0.2] : self.layerModel.bgColor;
}

@end
