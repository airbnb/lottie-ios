//
//  LOTRectInterpolator.m
//  Lottie
//
//  Created by brandon_withrow on 7/13/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTRectInterpolator.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTRectInterpolator

- (CGRect)rectValueForFrame:(NSNumber *)frame {
  CGFloat progress = [self progressForFrame:frame];
  if (progress == 0) {
    return self.leadingKeyframe.rectValue;
  }
  if (progress == 1) {
    return self.trailingKeyframe.rectValue;
  }
  return CGRectMake(0,
                    0,
                    LOT_RemapValue(progress, 0, 1, self.leadingKeyframe.sizeValue.width, self.trailingKeyframe.sizeValue.width),
                    LOT_RemapValue(progress, 0, 1, self.leadingKeyframe.sizeValue.height, self.trailingKeyframe.sizeValue.height));

}

@end
