//
//  LOTValueCallback.h
//  Lottie
//
//  Created by brandon_withrow on 12/15/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"

typedef UIColor * _Nonnull (^LOTColorValueCallbackBlock)(CGFloat startFrame,
                                                         CGFloat endFrame,
                                                         UIColor * _Nullable startColor,
                                                         UIColor * _Nullable endColor,
                                                         UIColor * _Nullable interpolatedColor,
                                                         CGFloat interpolatedProgress,
                                                         CGFloat currentFrame);

typedef CGFloat (^LOTNumberValueCallbackBlock)(CGFloat startFrame,
                                               CGFloat endFrame,
                                               CGFloat startValue,
                                               CGFloat endValue,
                                               CGFloat interpolatedValue,
                                               CGFloat interpolatedProgress,
                                               CGFloat currentFrame);

typedef CGPoint (^LOTPointValueCallbackBlock)(CGFloat startFrame,
                                              CGFloat endFrame,
                                              CGPoint startPoint,
                                              CGPoint endPoint,
                                              CGPoint interpolatedPoint,
                                              CGFloat interpolatedProgress,
                                              CGFloat currentFrame);

typedef CGSize (^LOTSizeValueCallbackBlock)(CGFloat startFrame,
                                            CGFloat endFrame,
                                            CGSize startSize,
                                            CGSize endSize,
                                            CGSize interpolatedSize,
                                            CGFloat interpolatedProgress,
                                            CGFloat currentFrame);

typedef UIBezierPath * _Nonnull (^LOTPathValueCallbackBlock)(CGFloat startFrame,
                                                             CGFloat endFrame,
                                                             CGFloat interpolatedProgress,
                                                             CGFloat currentFrame);

@interface LOTValueCallback : NSObject


@end

@interface LOTColorValueCallback : LOTValueCallback

+ (instancetype _Nonnull)withBlock:(LOTColorValueCallbackBlock _Nonnull )block;

@property (nonatomic, copy, nonnull) LOTColorValueCallbackBlock callback;

@end

@interface LOTNumberValueCallback : LOTValueCallback

+ (instancetype _Nonnull)withBlock:(LOTNumberValueCallbackBlock _Nonnull)block;

@property (nonatomic, copy, nonnull) LOTNumberValueCallbackBlock callback;

@end

@interface LOTPointValueCallback : LOTValueCallback

+ (instancetype _Nonnull)withBlock:(LOTPointValueCallbackBlock _Nonnull)block;

@property (nonatomic, copy, nonnull) LOTPointValueCallbackBlock callback;

@end

@interface LOTSizeValueCallback : LOTValueCallback

+ (instancetype _Nonnull)withBlock:(LOTSizeValueCallbackBlock _Nonnull)block;

@property (nonatomic, copy, nonnull) LOTSizeValueCallbackBlock callback;


@end

@interface LOTPathValueCallback : LOTValueCallback

+ (instancetype _Nonnull)withBlock:(LOTPathValueCallbackBlock _Nonnull)block;

@property (nonatomic, copy, nonnull) LOTPathValueCallbackBlock callback;


@end
