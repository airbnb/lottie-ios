//
//  LOTRepeaterRenderer.m
//  Lottie
//
//  Created by brandon_withrow on 7/28/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTRepeaterRenderer.h"
#import "LOTTransformInterpolator.h"
#import "LOTNumberInterpolator.h"
#import "LOTHelpers.h"

@implementation LOTRepeaterRenderer {
  LOTTransformInterpolator *_transformInterpolator;
  LOTNumberInterpolator *_copiesInterpolator;
  LOTNumberInterpolator *_offsetInterpolator;
  LOTNumberInterpolator *_startOpacityInterpolator;
  LOTNumberInterpolator *_endOpacityInterpolator;
  
  CALayer *_instanceLayer;
  CAReplicatorLayer *_replicatorLayer;
  CALayer *centerPoint_DEBUG;
}

- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nonnull)inputNode
                              shapeRepeater:(LOTShapeRepeater *_Nonnull)repeater {
  self = [super initWithInputNode:inputNode];
  if (self) {
    _transformInterpolator = [[LOTTransformInterpolator alloc] initWithPosition:repeater.position.keyframeGroup.keyframes
                                                                       rotation:repeater.rotation.keyframeGroup.keyframes
                                                                         anchor:repeater.anchorPoint.keyframeGroup.keyframes
                                                                          scale:repeater.scale.keyframeGroup.keyframes];
    _copiesInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:repeater.copies.keyframeGroup.keyframes];
    _offsetInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:repeater.offset.keyframeGroup.keyframes];
    _startOpacityInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:repeater.startOpacity.keyframeGroup.keyframes];
    _endOpacityInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:repeater.endOpacity.keyframeGroup.keyframes];
    
    _instanceLayer = [CALayer layer];
    [self recursivelyAddChildLayers:inputNode];
    
    _replicatorLayer = [CAReplicatorLayer layer];
    _replicatorLayer.actions = @{@"instanceCount" : [NSNull null],
                                 @"instanceTransform" : [NSNull null],
                                 @"instanceAlphaOffset" : [NSNull null]};
    [_replicatorLayer addSublayer:_instanceLayer];
    [self.outputLayer addSublayer:_replicatorLayer];
    
    centerPoint_DEBUG = [CALayer layer];
    centerPoint_DEBUG.bounds = CGRectMake(0, 0, 20, 20);
    if (ENABLE_DEBUG_SHAPES) {
      [self.outputLayer addSublayer:centerPoint_DEBUG];
    }
  }
  return self;
}

- (void)recursivelyAddChildLayers:(LOTAnimatorNode *)node {
  if ([node isKindOfClass:[LOTRenderNode class]]) {
    [_instanceLayer addSublayer:[(LOTRenderNode *)node outputLayer]];
  }
  if (![node isKindOfClass:[LOTRepeaterRenderer class]] &&
      node.inputNode) {
    [self recursivelyAddChildLayers:node.inputNode];
  }
}

- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  // TODO BW Add offset ability
  return ([_transformInterpolator hasUpdateForFrame:frame] ||
          [_copiesInterpolator hasUpdateForFrame:frame] ||
          [_startOpacityInterpolator hasUpdateForFrame:frame] ||
          [_endOpacityInterpolator hasUpdateForFrame:frame]);
}

- (void)performLocalUpdate {
  centerPoint_DEBUG.backgroundColor =  [UIColor greenColor].CGColor;
  centerPoint_DEBUG.borderColor = [UIColor lightGrayColor].CGColor;
  centerPoint_DEBUG.borderWidth = 2.f;
  
  CGFloat copies = ceilf([_copiesInterpolator floatValueForFrame:self.currentFrame]);
  _replicatorLayer.instanceCount = (NSInteger)copies;
  _replicatorLayer.instanceTransform = [_transformInterpolator transformForFrame:self.currentFrame];
  CGFloat startOpacity = [_startOpacityInterpolator floatValueForFrame:self.currentFrame];
  CGFloat endOpacity = [_endOpacityInterpolator floatValueForFrame:self.currentFrame];
  CGFloat opacityStep = (endOpacity - startOpacity) / copies;
  _instanceLayer.opacity = startOpacity;
  _replicatorLayer.instanceAlphaOffset = opacityStep;
}

@end
