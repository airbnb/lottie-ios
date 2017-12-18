//
//  LOTValueInterpolator.h
//  Pods
//
//  Created by brandon_withrow on 7/10/17.
//
//

#import <Foundation/Foundation.h>
#import "LOTKeyframe.h"
#import "LOTValueCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface LOTValueInterpolator : NSObject

- (instancetype)initWithKeyframes:(NSArray <LOTKeyframe *> *)keyframes;

/// Used to dynamically update keyframe data.
- (BOOL)setValue:(id)value atFrame:(NSNumber *)frame __deprecated;
- (id _Nullable)keyframeDataForValue:(id)value;

@property (nonatomic, weak, nullable) LOTKeyframe *leadingKeyframe;
@property (nonatomic, weak, nullable) LOTKeyframe *trailingKeyframe;
@property (nonatomic, readonly) BOOL hasValueOverride;

- (void)setValueCallback:(LOTValueCallback *)valueCallback;

- (BOOL)hasUpdateForFrame:(NSNumber *)frame;
- (CGFloat)progressForFrame:(NSNumber *)frame;

@end

NS_ASSUME_NONNULL_END
