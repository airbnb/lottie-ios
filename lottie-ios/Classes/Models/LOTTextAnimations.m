//
//  LOTTextAnimations.m
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTTextAnimations.h"
#import "LOTKeyframe.h"

@implementation LOTTextAnimations

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {

  NSDictionary *animations = jsonDictionary[@"a"];
  if (animations) {
    NSDictionary *color = animations[@"fc"];
    if (color) {
      _fillColor = [[LOTKeyframeGroup alloc] initWithData:color];
    }

    NSDictionary *stroke = animations[@"sc"];
    if (stroke) {
      _strokeColor = [[LOTKeyframeGroup alloc] initWithData:stroke];
    }

    NSDictionary *strokeWidth = animations[@"sw"];
    if (strokeWidth) {
      _strokeWidth = [[LOTKeyframeGroup alloc] initWithData:strokeWidth];
    }

    NSDictionary *tracking = animations[@"t"];
    if (tracking) {
      _tracking = [[LOTKeyframeGroup alloc] initWithData:tracking];
    }
  }
}

@end

// Animators
// Done:
//  Fill Color
//  Stroke Width
//  Stroke Color
//  Tracking
//
// Pending: --
//  Position
//  Anchor Point
//  Scale
//  Skew
//  Skew Axis
//  Rotation
//  Opacity
//  Fill Hue
//  Fill Saturation
//  Fill Brightness
