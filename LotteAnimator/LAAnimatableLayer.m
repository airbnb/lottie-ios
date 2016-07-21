//
//  LAAnimatableLayer.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/21/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableLayer.h"

@implementation LAAnimatableLayer

- (void)play {
  [self _resumeLayer:self];
  for (CALayer *layer in self.animationSublayers) {
    [self _resumeLayer:layer];
  }
  
  for (LAAnimatableLayer *layer in self.childLayers) {
    [layer play];
  }
}

- (void)pause {
  [self _pauseLayer:self];
  for (CALayer *layer in self.animationSublayers) {
    [self _pauseLayer:layer];
  }
  
  for (LAAnimatableLayer *layer in self.childLayers) {
    [layer pause];
  }
}

- (void)setLoopAnimation:(BOOL)loopAnimation {
  self.repeatCount = loopAnimation ? HUGE_VALF : 0;
  for (CALayer *layer in self.animationSublayers) {
    layer.repeatCount = loopAnimation ? HUGE_VALF : 0;
  }
  
  for (LAAnimatableLayer *layer in self.childLayers) {
    [layer setLoopAnimation:loopAnimation];
  }
}

- (void)setAnimationProgress:(CGFloat)animationProgress {
  self.speed = 0.0;
  self.timeOffset = 0.0;
  self.beginTime = 0.0;
  self.beginTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
  self.timeOffset = [self convertTime:CACurrentMediaTime() fromLayer:nil] + animationProgress;
  
  for (CALayer *layer in self.animationSublayers) {
    layer.speed = 0.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    layer.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.timeOffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil] + animationProgress;
  }
  
  for (LAAnimatableLayer *layer in self.childLayers) {
    [layer setAnimationProgress:animationProgress];
  }
  
}

- (void)setAutoReverseAnimation:(BOOL)autoReverseAnimation {
  self.autoreverses = autoReverseAnimation;
  for (CALayer *layer in self.animationSublayers) {
    layer.autoreverses = autoReverseAnimation;
  }
  
  for (LAAnimatableLayer *layer in self.childLayers) {
    [layer setAutoReverseAnimation:autoReverseAnimation];
  }
}

-(void)_pauseLayer:(CALayer*)layer {
  CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
  layer.speed = 0.0;
  layer.timeOffset = pausedTime;
}

-(void)_resumeLayer:(CALayer*)layer {
  CFTimeInterval pausedTime = [layer timeOffset];
  layer.speed = 1.0;
  layer.timeOffset = 0.0;
  layer.beginTime = 0.0;
  CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
  layer.beginTime = timeSincePause;
}


@end
