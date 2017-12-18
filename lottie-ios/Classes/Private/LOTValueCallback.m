//
//  LOTValueCallback.m
//  Lottie
//
//  Created by brandon_withrow on 12/15/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTValueCallback.h"

@implementation LOTValueCallback

@end

@implementation LOTColorValueCallback

+ (instancetype)withBlock:(LOTColorValueCallbackBlock)block {
  LOTColorValueCallback *colorCallback = [[LOTColorValueCallback alloc] init];
  colorCallback.callback = block;
  return colorCallback;
}

@end

@implementation LOTNumberValueCallback

+ (instancetype)withBlock:(LOTNumberValueCallbackBlock)block {
  LOTNumberValueCallback *numberCallback = [[LOTNumberValueCallback alloc] init];
  numberCallback.callback = block;
  return numberCallback;
}

@end

@implementation LOTPointValueCallback

+ (instancetype)withBlock:(LOTPointValueCallbackBlock)block {
  LOTPointValueCallback *callback = [[LOTPointValueCallback alloc] init];
  callback.callback = block;
  return callback;
}

@end

@implementation LOTSizeValueCallback

+ (instancetype)withBlock:(LOTSizeValueCallbackBlock)block {
  LOTSizeValueCallback *callback = [[LOTSizeValueCallback alloc] init];
  callback.callback = block;
  return callback;
}

@end

@implementation LOTPathValueCallback

+ (instancetype)withBlock:(LOTPathValueCallbackBlock)block {
  LOTPathValueCallback *callback = [[LOTPathValueCallback alloc] init];
  callback.callback = block;
  return callback;
}

@end
