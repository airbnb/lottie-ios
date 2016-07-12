//
//  LAMask.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAMask.h"
#import "LAAnimatableShapeValue.h"
#import "LAAnimatableNumberValue.h"

@implementation LAMask

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSNumber *closed = jsonDictionary[@"cl"];
  _closed = closed.boolValue;
  
  NSNumber *inverted = jsonDictionary[@"inv"];
  _inverted = inverted.boolValue;
  
  NSString *mode = jsonDictionary[@"mode"];
  if ([mode isEqualToString:@"a"]) {
    _maskMode = LAMaskModeAdd;
  } else if ([mode isEqualToString:@"s"]) {
    _maskMode = LAMaskModeSubtract;
  } else if ([mode isEqualToString:@"i"]) {
    _maskMode = LAMaskModeIntersect;
  } else {
    _maskMode = LAMaskModeUnknown;
  }
  
  NSDictionary *maskshape = jsonDictionary[@"pt"];
  if (maskshape) {
    _maskPath = [[LAAnimatableShapeValue alloc] initWithShapeValues:maskshape closed:_closed];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity];
  }
}

@end
