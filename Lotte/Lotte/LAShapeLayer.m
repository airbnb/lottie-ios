//
//  LAShapeLayer.m
//  Lotte
//
//  Created by brandon_withrow on 8/15/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAShapeLayer.h"

@implementation LAShapeLayer {
  CAShapeLayer *_strokeLayer;
  CAShapeLayer *_strokeOffsetLayer;
  CAShapeLayer *_fillLayer;
}

@dynamic path, fillColor, strokeColor, lineWidth, strokeStart, strokeEnd, strokeOffset, fillOpacity, strokeOpacity;

- (instancetype)init {
  self = [super init];
  if (self) {
    [self _commonInit];
  }
  return self;
}
- (instancetype)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    [self _commonInit];
    if ([layer isKindOfClass:[LAShapeLayer class]]) {
      self.path = ((LAShapeLayer *)layer).path;
      self.fillColor = ((LAShapeLayer *)layer).fillColor;
      self.strokeColor = ((LAShapeLayer *)layer).strokeColor;
      self.lineWidth = ((LAShapeLayer *)layer).lineWidth;
      self.strokeStart = ((LAShapeLayer *)layer).strokeStart;
      self.strokeEnd = ((LAShapeLayer *)layer).strokeEnd;
      self.strokeOffset = ((LAShapeLayer *)layer).strokeOffset;
      self.lineDashPattern = ((LAShapeLayer *)layer).lineDashPattern;
      self.lineCap = ((LAShapeLayer *)layer).lineCap;
      self.lineJoin = ((LAShapeLayer *)layer).lineJoin;
      self.fillOpacity = ((LAShapeLayer *)layer).fillOpacity;
      self.strokeOpacity = ((LAShapeLayer *)layer).strokeOpacity;
    }
  }
  return self;
}

- (void)_commonInit {
  _fillLayer = [CAShapeLayer layer];
  _fillLayer.allowsEdgeAntialiasing = YES;
  [self addSublayer:_fillLayer];
  
  _strokeLayer = [CAShapeLayer layer];
  _strokeLayer.fillColor = nil;
  _strokeLayer.allowsEdgeAntialiasing = YES;
  [self addSublayer:_strokeLayer];
  
  _strokeOffsetLayer = [CAShapeLayer layer];
  _strokeOffsetLayer.fillColor = nil;
  _strokeOffsetLayer.allowsEdgeAntialiasing = YES;
  [self addSublayer:_strokeOffsetLayer];
}

- (void)setLineCap:(NSString *)lineCap {
  _lineCap = lineCap;
  _strokeLayer.lineCap = lineCap;
  _strokeOffsetLayer.lineCap = lineCap;
}

- (void)setLineJoin:(NSString *)lineJoin {
  _lineJoin = lineJoin;
  _strokeLayer.lineJoin = lineJoin;
  _strokeOffsetLayer.lineJoin = lineJoin;
}

- (void)setLineDashPattern:(NSArray<NSNumber *> *)lineDashPattern {
  _lineDashPattern = lineDashPattern;
  _strokeOffsetLayer.lineDashPattern = lineDashPattern;
  _strokeLayer.lineDashPattern = lineDashPattern;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  BOOL needsDisplay = [super needsDisplayForKey:key];
  
  if ([key isEqualToString:@"path"] ||
      [key isEqualToString:@"fillColor"] ||
      [key isEqualToString:@"strokeColor"] ||
      [key isEqualToString:@"lineWidth"] ||
      [key isEqualToString:@"strokeStart"] ||
      [key isEqualToString:@"strokeEnd"] ||
      [key isEqualToString:@"strokeOffset"] ||
      [key isEqualToString:@"fillOpacity"] ||
      [key isEqualToString:@"strokeOpacity"]) {
    needsDisplay = YES;
  }
  
  return needsDisplay;
}

-(id<CAAction>)actionForKey:(NSString *)event {
  if([event isEqualToString:@"path"] ||
     [event isEqualToString:@"fillColor"] ||
     [event isEqualToString:@"strokeColor"] ||
     [event isEqualToString:@"lineWidth"] ||
     [event isEqualToString:@"strokeStart"] ||
     [event isEqualToString:@"strokeEnd"] ||
     [event isEqualToString:@"strokeOffset"] ||
     [event isEqualToString:@"fillOpacity"] ||
     [event isEqualToString:@"strokeOpacity"]) {
    CABasicAnimation *theAnimation = [CABasicAnimation
                                      animationWithKeyPath:event];
    theAnimation.fromValue = [[self presentationLayer] valueForKey:event];
    return theAnimation;
  }
  return [super actionForKey:event];
}

- (void)display {
  LAShapeLayer *displayLayer = (LAShapeLayer *)self.presentationLayer;
  if (displayLayer == nil) {
    displayLayer = self;
  }
  _fillLayer.path = displayLayer.path;
  _fillLayer.fillColor = displayLayer.fillColor;
  _fillLayer.opacity = displayLayer.fillOpacity;
  
  _strokeLayer.path = displayLayer.path;
  _strokeLayer.strokeColor = displayLayer.strokeColor;
  _strokeLayer.lineWidth = displayLayer.lineWidth;
  _strokeLayer.opacity = displayLayer.strokeOpacity;
}

@end
