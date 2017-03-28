//
//  LOTAnimatableScaleValue.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableScaleValue.h"

@interface LOTAnimatableScaleValue ()

@property (nonatomic, readonly) NSArray<NSNumber *> *xScaleKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *yScaleKeyframes;
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
    if (scaleValues[@"x"]) {
      NSLog(@"%s: Warning: expressions are not supported", __PRETTY_FUNCTION__);
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes {
  
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray<NSValue *> *xScaleValues = [NSMutableArray array];
  NSMutableArray<NSValue *> *yScaleValues = [NSMutableArray array];
  
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
      CGVector vectorValue = [self _vectorForValueArray:outValue];
      [xScaleValues addObject:@(vectorValue.dx)];
      [yScaleValues addObject:@(vectorValue.dy)];
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
        CGVector vectorValue = [self _vectorForValueArray:startValue];
        [xScaleValues addObject:@(vectorValue.dx)];
        [yScaleValues addObject:@(vectorValue.dy)];
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
      CGVector vectorValue = [self _vectorForValueArray:endValue];
      [xScaleValues addObject:@(vectorValue.dx)];
      [yScaleValues addObject:@(vectorValue.dy)];
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
  _xScaleKeyframes = xScaleValues;
  _yScaleKeyframes = yScaleValues;
  _keyTimes = keyTimes;
  _timingFunctions = timingFunctions;
}

- (CGVector)_vectorForValueArray:(NSArray<NSNumber *> *)value {
  if (value.count >=2) {
    return CGVectorMake(value[0].floatValue / 100.f, value[1].floatValue / 100.f);
  }
  return CGVectorMake(1.0, 1.0);
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
  return (self.xScaleKeyframes.count > 0);
}

- (NSArray<CAKeyframeAnimation *> *)animationsForKeyPath:(NSString *)keypath {
  if (self.hasAnimation == NO) {
    return @[];
  }
  NSAssert([keypath hasSuffix:@"transform.scale"], @"Lottie: %@ must be applied to a 'transform.scale' keypath", self);

  NSString *xKeypath = [keypath stringByAppendingString:@".x"];
  CAKeyframeAnimation *xKeyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:xKeypath];
  xKeyframeAnimation.keyTimes = self.keyTimes;
  xKeyframeAnimation.values = self.xScaleKeyframes;
  xKeyframeAnimation.timingFunctions = self.timingFunctions;
  xKeyframeAnimation.duration = self.duration;
  xKeyframeAnimation.beginTime = self.delay;
  xKeyframeAnimation.fillMode = kCAFillModeForwards;

  NSString *yKeypath = [keypath stringByAppendingString:@".y"];
  CAKeyframeAnimation *yKeyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:yKeypath];
  yKeyframeAnimation.keyTimes = self.keyTimes;
  yKeyframeAnimation.values = self.yScaleKeyframes;
  yKeyframeAnimation.timingFunctions = self.timingFunctions;
  yKeyframeAnimation.duration = self.duration;
  yKeyframeAnimation.beginTime = self.delay;
  yKeyframeAnimation.fillMode = kCAFillModeForwards;

  return @[xKeyframeAnimation, yKeyframeAnimation];
}

@end
