//
//  LOTAnimatableScaleValue.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableScaleValue.h"

@interface LOTAnimatableScaleValue ()

@property (nonatomic, readonly) NSArray<NSValue *> *scaleKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSTimeInterval delay;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) BOOL hasAnimation;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;
@property (nonatomic, readonly) NSNumber *frameRate;

@end

@implementation LOTAnimatableScaleValue

- (instancetype)initWithScaleValues:(NSDictionary *)scaleValues frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _frameRate = frameRate;
    id value = scaleValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSArray *)value firstObject][@"t"]) {
      //Keframes
      [self _buildAnimationForKeyframes:value];
    } else {
      //Single Value, no animation
      _initialScale = [self _xformForValueArray:value];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes {
  
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray<NSValue *> *scaleValues = [NSMutableArray array];
  
  _startFrame = keyframes.firstObject[@"t"];
  NSNumber *endFrame = keyframes.lastObject[@"t"];
  
  NSAssert((_startFrame && endFrame && _startFrame.integerValue < endFrame.integerValue),
           @"Lottie: Keyframe animation has incorrect time values or invalid number of keyframes");
  // Calculate time duration
  _durationFrames = @(endFrame.floatValue - _startFrame.floatValue);
  
  _duration = _durationFrames.floatValue / _frameRate.floatValue;
  _delay = _startFrame.floatValue / _frameRate.floatValue;
  
  BOOL addStartValue = YES;
  BOOL addTimePadding = NO;
  NSArray *outValue = nil;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - _startFrame.floatValue) / _durationFrames.floatValue);
    
    if (outValue) {
      //add out value
      [scaleValues addObject:[NSValue valueWithCATransform3D:[self _xformForValueArray:outValue]]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outValue = nil;
    }
    
    NSArray *startValue = keyframe[@"s"];
    if (addStartValue) {
      // Add start value
      if (startValue) {
        if (keyframe == keyframes.firstObject) {
          _initialScale = [self _xformForValueArray:startValue];
        }
        [scaleValues addObject:[NSValue valueWithCATransform3D:[self _xformForValueArray:startValue]]];
        if (timingFunctions.count) {
          [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
      }
      addStartValue = NO;
    }
    
    if (addTimePadding) {
      // add time padding
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:[holdPercentage copy]];
      addTimePadding = NO;
    }
    
    // add end value if present for keyframe
    NSArray *endValue = keyframe[@"e"];
    if (endValue) {
      [scaleValues addObject:[NSValue valueWithCATransform3D:[self _xformForValueArray:endValue]]];
      /*
       * Timing Function for time interpolations between keyframes
       * Should be n-1 where n is the number of keyframes
       */
      CAMediaTimingFunction *timingFunction;
      NSDictionary *timingControlPoint1 = keyframe[@"o"];
      NSDictionary *timingControlPoint2 = keyframe[@"i"];
      
      if (timingControlPoint1 && timingControlPoint2) {
        // Easing function
        CGPoint cp1 = [self _pointFromValueDict:timingControlPoint1];
        CGPoint cp2 = [self _pointFromValueDict:timingControlPoint2];
        timingFunction = [CAMediaTimingFunction functionWithControlPoints:cp1.x :cp1.y :cp2.x :cp2.y];
      } else {
        // No easing function specified, fallback to linear
        timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
      }
      [timingFunctions addObject:timingFunction];
    }
    
    // add time
    [keyTimes addObject:timePercentage];
    
    // Check if keyframe is a hold keyframe
    if ([keyframe[@"h"] boolValue]) {
      // set out value as start and flag next frame accordinly
      outValue = startValue;
      addStartValue = YES;
      addTimePadding = YES;
    }
  }
  _scaleKeyframes = scaleValues;
  _keyTimes = keyTimes;
  _timingFunctions = timingFunctions;
}

- (CATransform3D)_xformForValueArray:(NSArray *)value {
  if (value.count >=2) {
    return CATransform3DMakeScale([value[0] floatValue] / 100.f, [value[1] floatValue] / 100.f, 1);
  }
  return CATransform3DIdentity;
}

- (CGPoint)_pointFromValueDict:(NSDictionary *)values {
  NSNumber *xValue = @0, *yValue = @0;
  if ([values[@"x"] isKindOfClass:[NSNumber class]]) {
    xValue = values[@"x"];
  } else if ([values[@"x"] isKindOfClass:[NSArray class]]) {
    xValue = values[@"x"][0];
  }
  
  if ([values[@"y"] isKindOfClass:[NSNumber class]]) {
    yValue = values[@"y"];
  } else if ([values[@"y"] isKindOfClass:[NSArray class]]) {
    yValue = values[@"y"][0];
  }
  
  return CGPointMake([xValue floatValue], [yValue floatValue]);
}

- (BOOL)hasAnimation {
  return (self.scaleKeyframes.count > 0);
}

- (nullable CAKeyframeAnimation *)animationForKeyPath:(nonnull NSString *)keypath {
  if (self.hasAnimation == NO) {
    return nil;
  }
  CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:keypath];
  keyframeAnimation.keyTimes = self.keyTimes;
  keyframeAnimation.values = self.scaleKeyframes;
  keyframeAnimation.timingFunctions = self.timingFunctions;
  keyframeAnimation.duration = self.duration;
  keyframeAnimation.beginTime = self.delay;
  keyframeAnimation.fillMode = kCAFillModeForwards;
  return keyframeAnimation;
}

@end
