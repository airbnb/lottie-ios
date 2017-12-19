//
//  LOTColorInterpolator.m
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTColorInterpolator.h"
#import "LOTPlatformCompat.h"
#import "UIColor+Expanded.h"

@implementation LOTColorInterpolator

- (UIColor *)colorForFrame:(NSNumber *)frame {
  CGFloat progress = [self progressForFrame:frame];
  UIColor *returnColor;

  if (progress == 0) {
    returnColor = self.leadingKeyframe.colorValue;
  } else if (progress == 1) {
    returnColor = self.trailingKeyframe.colorValue;
  } else {
    returnColor = [UIColor LOT_colorByLerpingFromColor:self.leadingKeyframe.colorValue toColor:self.trailingKeyframe.colorValue amount:progress];
  }
  if (self.hasValueOverride) {
    return self.colorCallback.callback(self.leadingKeyframe.keyframeTime.floatValue, self.trailingKeyframe.keyframeTime.floatValue, self.leadingKeyframe.colorValue, self.trailingKeyframe.colorValue, returnColor, progress, frame.floatValue);
  }

  return returnColor;
}

- (void)setValueCallback:(LOTValueCallback *)valueCallback {
  NSAssert(([valueCallback isKindOfClass:[LOTColorValueCallback class]]), @"Color Interpolator set with incorrect callback type. Expected LOTColorValueCallback");
  self.colorCallback = (LOTColorValueCallback *)valueCallback;
}

- (BOOL)hasValueOverride {
  return self.colorCallback != nil;
}

@end
