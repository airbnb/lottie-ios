//
//  LOTStrokeRenderer.m
//  Lottie
//
//  Created by brandon_withrow on 7/17/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTStrokeRenderer.h"
#import "LOTColorInterpolator.h"
#import "LOTNumberInterpolator.h"

@implementation LOTStrokeRenderer {
  LOTColorInterpolator *_colorInterpolator;
  LOTNumberInterpolator *_opacityInterpolator;
  LOTNumberInterpolator *_widthInterpolator;
}

- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nonnull)inputNode
                                shapeStroke:(LOTShapeStroke *_Nonnull)stroke {
  self = [super initWithInputNode:inputNode];
  if (self) {
    _colorInterpolator = [[LOTColorInterpolator alloc] initWithKeyframes:stroke.color.keyframes];
    _opacityInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:stroke.opacity.keyframes];
    _widthInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:stroke.width.keyframes];
    self.outputLayer.fillColor = nil;
    self.outputLayer.lineDashPattern = stroke.lineDashPattern;
    self.outputLayer.lineCap = stroke.capType == LOTLineCapTypeRound ? kCALineCapRound : kCALineCapButt;
  }
  return self;
}

- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  return ([_colorInterpolator hasUpdateForFrame:frame] ||
          [_opacityInterpolator hasUpdateForFrame:frame] ||
          [_widthInterpolator hasUpdateForFrame:frame]);
}

- (void)performLocalUpdate {
  self.outputLayer.strokeColor = [_colorInterpolator colorForFrame:self.currentFrame].CGColor;
  self.outputLayer.lineWidth = [_widthInterpolator floatValueForFrame:self.currentFrame];
  self.outputLayer.opacity = [_opacityInterpolator floatValueForFrame:self.currentFrame];
}

- (void)rebuildOutputs {
  self.outputLayer.path = self.inputNode.outputPath.CGPath;
}

- (NSDictionary *)actionsForRenderLayer {
  return @{@"strokeColor": [NSNull null],
           @"lineWidth": [NSNull null],
           @"opacity" : [NSNull null]};
}

@end
