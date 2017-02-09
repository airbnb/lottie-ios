//
//  LOTStrokeShapeLayer.m
//  Pods
//
//  Created by Brandon Withrow on 2/7/17.
//
//

#import "LOTStrokeShapeLayer.h"

@implementation LOTStrokeShapeLayer

@dynamic trimEnd;
@dynamic trimStart;
@dynamic trimOffset;

- (instancetype)init {
  self = [super init];
  if (self) {
    [self _commonInit];
  }
  return self;
}

- (instancetype)initWithLayer:(id)layer {
  if( ( self = [super initWithLayer:layer] ) ) {
    if ([layer isKindOfClass:[LOTStrokeShapeLayer class]]) {
      self.trimEnd = ((LOTStrokeShapeLayer *)layer).trimEnd;
      self.trimStart = ((LOTStrokeShapeLayer *)layer).trimStart;
      self.trimOffset = ((LOTStrokeShapeLayer *)layer).trimOffset;
    }
  }
  return self;
}

- (void)_commonInit {
  self.trimStart = 0;
  self.trimOffset = 0;
  self.trimEnd = 1;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  BOOL needsDisplay = [super needsDisplayForKey:key];
  
  if ([key isEqualToString:@"trimEnd"] || [key isEqualToString:@"trimStart"] || [key isEqualToString:@"trimOffset"]) {
    needsDisplay = YES;
  }
  
  return needsDisplay;
}

- (void)display {
  LOTStrokeShapeLayer *presentationLayer = (LOTStrokeShapeLayer *)self.presentationLayer;
  if (presentationLayer == nil) {
    presentationLayer = self;
  }

  CGFloat threeSixty = 360;
  CGFloat offsetAmount = fmodf(fabs(presentationLayer.trimOffset) , threeSixty) / threeSixty;
  offsetAmount = presentationLayer.trimOffset < 0 ? offsetAmount * -1 : offsetAmount;
  BOOL startFirst = presentationLayer.trimStart < presentationLayer.trimEnd;
  
  CGFloat trimStart = (startFirst ? presentationLayer.trimStart : presentationLayer.trimEnd) + offsetAmount;
  CGFloat trimEnd = (startFirst ? presentationLayer.trimEnd : presentationLayer.trimStart) + offsetAmount;
  
  if (trimEnd > 1 || trimStart > 1) {
    trimStart = trimStart - 1;
    trimEnd = trimEnd - 1;
  }
  if (trimStart < 0 || trimEnd < 0) {
    trimStart = trimStart + 1;
    trimEnd = trimEnd + 1;
  }
  
  trimStart = trimStart * 0.5;
  trimEnd = trimEnd * 0.5;
  
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  
  self.strokeStart = MAX(trimStart, 0);
  self.strokeEnd = MIN(trimEnd, 1);
  
  [CATransaction commit];
}

@end
