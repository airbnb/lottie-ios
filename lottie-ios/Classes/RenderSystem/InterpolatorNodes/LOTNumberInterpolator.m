//
//  LOTNumberInterpolator.m
//  Lottie
//
//  Created by brandon_withrow on 7/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTNumberInterpolator.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTNumberInterpolator

- (CGFloat)floatValueForFrame:(NSNumber *)frame {
  CGFloat progress = [self progressForFrame:frame];
  CGFloat returnValue;
  if (progress == 0) {
    returnValue = self.leadingKeyframe.floatValue;
  } else if (progress == 1) {
    returnValue = self.trailingKeyframe.floatValue;
  } else {
    returnValue = LOT_RemapValue(progress, 0, 1, self.leadingKeyframe.floatValue, self.trailingKeyframe.floatValue);
  }
  if (self.hasValueOverride) {
    return self.numberCallback.callback(self.leadingKeyframe.keyframeTime.floatValue, self.trailingKeyframe.keyframeTime.floatValue, self.leadingKeyframe.floatValue, self.trailingKeyframe.floatValue, returnValue, progress, frame.floatValue);
  }

  return returnValue;
}

- (BOOL)hasValueOverride {
  return self.numberCallback != nil;
}

- (void)setValueCallback:(LOTValueCallback *)valueCallback {
  NSAssert(([valueCallback isKindOfClass:[LOTNumberValueCallback class]]), @"Number Interpolator set with incorrect callback type. Expected LOTNumberValueCallback");
  self.numberCallback = (LOTNumberValueCallback*)valueCallback;
}

@end
