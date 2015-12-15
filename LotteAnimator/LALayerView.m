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
      LAMask *maskModel = model.masks.firstObject;
      UIBezierPath *myClippingPath = [maskModel.maskPath bezierPath:maskModel.isClosed];
      
      CAShapeLayer *mask = [CAShapeLayer layer];
      mask.path = myClippingPath.CGPath;

      self.layer.mask = mask;
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
