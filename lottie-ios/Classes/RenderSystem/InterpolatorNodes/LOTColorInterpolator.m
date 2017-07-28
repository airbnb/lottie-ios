//
//  LOTColorInterpolator.m
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTColorInterpolator.h"
#import "UIColor+Expanded.h"

@implementation LOTColorInterpolator

- (UIColor *)colorForFrame:(NSNumber *)frame {
  CGFloat progress = [self progressForFrame:frame];
  if (progress == 0) {
    return self.leadingKeyframe.colorValue;
  }
  if (progress == 1) {
    return self.trailingKeyframe.colorValue;
  }
  UIColor *returnColor = [UIColor LOT_colorByLerpingFromColor:self.leadingKeyframe.colorValue toColor:self.trailingKeyframe.colorValue amount:progress];
  return returnColor;
}

@end
