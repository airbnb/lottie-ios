//
//  LOTValueInterpolator.m
//  Pods
//
//  Created by brandon_withrow on 7/10/17.
//
//

#import "LOTValueInterpolator.h"
#import "CGGeometry+LOTAdditions.h"

@interface LOTValueInterpolator ()

@property (nonatomic, strong) NSArray<LOTKeyframe *> *keyframes;

@end

@implementation LOTValueInterpolator {
}

- (instancetype)initWithKeyframes:(NSArray <LOTKeyframe *> *)keyframes {
  self = [super init];
  if (self) {
    _keyframes = keyframes;
  }
  return self;
}

- (id)keyframeDataForValue:(id)value  {
  NSLog(@"%s: Unsupported Keyframe Data: %@", __PRETTY_FUNCTION__, value);
  return nil;
}

// Change keyframe data
- (BOOL)setValue:(id)value atFrame:(NSNumber *)frame {
  id data = [self keyframeDataForValue:value];
  if (data == nil) {
    return NO;
  }
  if (frame == nil) {
    frame = @0;
  }
  [self updateKeyframeSpanForFrame:frame];
  if (frame.floatValue == self.leadingKeyframe.keyframeTime.floatValue) {
    // Is leading frame, replace
    LOTKeyframe *newKeyframe = [self.leadingKeyframe copyWithData:data];
    NSMutableArray *keyframes = [NSMutableArray arrayWithArray:_keyframes];
    NSUInteger idx = [keyframes indexOfObject:self.leadingKeyframe];
    [keyframes replaceObjectAtIndex:idx withObject:newKeyframe];
    self.leadingKeyframe = newKeyframe;
    _keyframes = keyframes;
  } else if (frame.floatValue == self.trailingKeyframe.keyframeTime.floatValue) {
    // Is trailing frame
    LOTKeyframe *newKeyframe = [self.trailingKeyframe copyWithData:data];
    NSMutableArray *keyframes = [NSMutableArray arrayWithArray:_keyframes];
    NSUInteger idx = [keyframes indexOfObject:self.trailingKeyframe];
    [keyframes replaceObjectAtIndex:idx withObject:newKeyframe];
    self.trailingKeyframe = newKeyframe;
    _keyframes = keyframes;
  } else {
    // Is between leading and trailing. Either can be nil.
    // For now added keyframes will default to linear interpolation.
    // TODO BW Add smart bezier interpolation
    NSMutableDictionary *keyframeDict = [NSMutableDictionary dictionary];
    keyframeDict[@"s"] = data;
    keyframeDict[@"t"] = frame;
    LOTKeyframe *keyframe = [[LOTKeyframe alloc] initWithKeyframe:keyframeDict];
    NSMutableArray *newKeyframes = [NSMutableArray arrayWithArray:_keyframes];
    if (self.trailingKeyframe == nil ||
        self.trailingKeyframe == newKeyframes.lastObject) {
      [newKeyframes addObject:keyframe];
    } else {
      NSInteger idx = [newKeyframes indexOfObject:self.trailingKeyframe];
      [newKeyframes insertObject:keyframe atIndex:idx];
    }
    _keyframes = newKeyframes;
    self.leadingKeyframe = nil;
    self.trailingKeyframe = nil;
  }
  
  return YES;
}

- (BOOL)hasUpdateForFrame:(NSNumber *)frame {
  /*
   Cases we dont update keyframe
   if time is in span and leading keyframe is hold
   if trailing keyframe is nil and time is after leading
   if leading keyframe is nil and time is before trailing
   */
  if (self.leadingKeyframe &&
      self.trailingKeyframe == nil &&
      self.leadingKeyframe.keyframeTime.floatValue < frame.floatValue) {
    // Frame is after bounds of keyframes. Clip
    return NO;
  }
  if (self.trailingKeyframe &&
      self.leadingKeyframe == nil &&
      self.trailingKeyframe.keyframeTime.floatValue > frame.floatValue) {
    // Frame is before keyframes bounds. Clip.
    return NO;
  }
  if (self.leadingKeyframe && self.trailingKeyframe &&
      self.leadingKeyframe.isHold &&
      self.leadingKeyframe.keyframeTime.floatValue < frame.floatValue &&
      self.trailingKeyframe.keyframeTime.floatValue > frame.floatValue) {
    // Frame is in span and current span is a hold keyframe
    return NO;
  }
  
  return YES;
}

- (void)updateKeyframeSpanForFrame:(NSNumber *)frame {
  if (self.leadingKeyframe == nil &&
      self.trailingKeyframe == nil) {
    // Set Initial Keyframes
    LOTKeyframe *first = _keyframes.firstObject;
    if (first.keyframeTime.floatValue > 0) {
      self.trailingKeyframe = first;
    } else {
      self.leadingKeyframe = first;
      if (_keyframes.count > 1) {
        self.trailingKeyframe = _keyframes[1];
      }
    }
  }
  if (self.trailingKeyframe && frame.floatValue >= self.trailingKeyframe.keyframeTime.floatValue) {
    // Frame is after current span, can move forward
    NSInteger index = [_keyframes indexOfObject:self.trailingKeyframe];
    BOOL keyframeFound = NO;
    
    LOTKeyframe *testLeading = self.trailingKeyframe;
    LOTKeyframe *testTrailing = nil;
    
    while (keyframeFound == NO) {
      index ++;
      if (index < _keyframes.count) {
        testTrailing = _keyframes[index];
        if (frame.floatValue < testTrailing.keyframeTime.floatValue) {
          // This is the span.
          keyframeFound = YES;
        } else {
          testLeading = testTrailing;
        }
      } else {
        // Leading is Last object
        testTrailing = nil;
        keyframeFound = YES;
      }
    }
    self.leadingKeyframe = testLeading;
    self.trailingKeyframe = testTrailing;
  } else if (self.leadingKeyframe && frame.floatValue < self.leadingKeyframe.keyframeTime.floatValue) {
    // Frame is before current span, can move back a span
    NSInteger index = [_keyframes indexOfObject:self.leadingKeyframe];
    BOOL keyframeFound = NO;
    
    LOTKeyframe *testLeading = nil;
    LOTKeyframe *testTrailing = self.leadingKeyframe;
    
    while (keyframeFound == NO) {
      index --;
      if (index >= 0) {
        testLeading = _keyframes[index];
        if (frame.floatValue >= testLeading.keyframeTime.floatValue) {
          // This is the span.
          keyframeFound = YES;
        } else {
          testTrailing = testLeading;
        }
      } else {
        // Trailing is first object
        testLeading = nil;
        keyframeFound = YES;
      }
    }
    self.leadingKeyframe = testLeading;
    self.trailingKeyframe = testTrailing;
  }
}

- (CGFloat)progressForFrame:(NSNumber *)frame {
  [self updateKeyframeSpanForFrame:frame];
  // At this point frame definitely exists between leading and trailing keyframes
  if (self.leadingKeyframe.keyframeTime == frame) {
    // Frame is leading keyframe
    return 0;
  }
  if (self.trailingKeyframe == nil) {
    // Frame is after end of keyframe timeline
    return 0;
  }
  if (self.leadingKeyframe.isHold) {
    // Hold Keyframe
    return 0;
  }
  if (self.leadingKeyframe == nil) {
    // Frame is before start of keyframe timeline
    return 1;
  }

  CGFloat progession = LOT_RemapValue(frame.floatValue, self.leadingKeyframe.keyframeTime.floatValue, self.trailingKeyframe.keyframeTime.floatValue, 0, 1);
  
  if ((self.leadingKeyframe.outTangent.x != self.leadingKeyframe.outTangent.y ||
      self.trailingKeyframe.inTangent.x != self.trailingKeyframe.inTangent.y) &&
      (!LOT_CGPointIsZero(self.leadingKeyframe.outTangent) &&
       !LOT_CGPointIsZero(self.trailingKeyframe.inTangent))) {
    // Bezeir Time Curve
    progession = LOT_CubicBezeirInterpolate(CGPointMake(0, 0), self.leadingKeyframe.outTangent, self.trailingKeyframe.inTangent, CGPointMake(1, 1), progession);
  }
  
  return progession;
}

@end
