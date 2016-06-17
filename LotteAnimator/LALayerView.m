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
      UIBezierPath *clippingMask = nil;
      for (LAMask *maskModel in model.masks) {
        UIBezierPath *maskPath = [maskModel.maskPath bezierPath:maskModel.isClosed];
        if (clippingMask) {
          [clippingMask appendPath:maskPath];
        } else {
          clippingMask = maskPath;
        }
      }
      CAShapeLayer *mask = [CAShapeLayer layer];
      mask.path = clippingMask.CGPath;

      self.layer.mask = mask;
    }
    
    if (model.shapes) {
      self.clipsToBounds = NO;
      for (LAShape *shape in model.shapes) {
        NSMutableArray *paths = [shape.paths mutableCopy];
        
        NSArray *allItems = shape.shapeItems;
        NSArray *reversedItems = [[allItems reverseObjectEnumerator] allObjects];

        LAShapeTransform *transformItem = shape.transforms.firstObject;
        
        for (LAShapeItem *item in reversedItems) {
          // Reverse Enumerate to build up shape heirarchy.
          // TODO track items.
          if ([item isKindOfClass:[LAShapeFill class]]) {
            LAShapeFill *fill = (LAShapeFill *)item;
            for (LAShapeItem *path in paths) {
              CAShapeLayer *shapeLayer = [CAShapeLayer layer];
              shapeLayer.path = path.path.CGPath;
              shapeLayer.fillColor = fill.color.CGColor;
              shapeLayer.opacity = fill.alpha;
              shapeLayer.transform = CATransform3DMakeAffineTransform(transformItem.transform);
              [self.layer addSublayer:shapeLayer];
            }
          }
          
          if ([item isKindOfClass:[LAShapeStroke class]]) {
            LAShapeStroke *stroke = (LAShapeStroke *)item;
            for (LAShapeItem *path in paths) {
              CAShapeLayer *shapeLayer = [CAShapeLayer layer];
              shapeLayer.path = path.path.CGPath;
              shapeLayer.fillColor = nil;
              shapeLayer.strokeColor = stroke.color.CGColor;
              shapeLayer.lineWidth = stroke.width.floatValue;
              shapeLayer.opacity = stroke.alpha;
              shapeLayer.transform = CATransform3DMakeAffineTransform(transformItem.transform);
              [self.layer addSublayer:shapeLayer];
            }
          }
          if ([paths containsObject:item]) {
            [paths removeObject:item];
          }
        }
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
