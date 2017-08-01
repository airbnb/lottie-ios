//
//  LOTValueInterpolator.h
//  Pods
//
//  Created by brandon_withrow on 7/10/17.
//
//

#import <Foundation/Foundation.h>
#import "LOTKeyframe.h"

NS_ASSUME_NONNULL_BEGIN

@interface LOTValueInterpolator : NSObject

- (instancetype)initWithKeyframes:(NSArray <LOTKeyframe *> *)keyframes;

/// Used to dynamically update keyframe data.
- (BOOL)setValue:(id)value atFrame:(NSNumber *)frame;
- (id)keyframeDataForValue:(id)value;

@property (nonatomic, weak, nullable) LOTKeyframe *leadingKeyframe;
@property (nonatomic, weak, nullable) LOTKeyframe *trailingKeyframe;

- (BOOL)hasUpdateForFrame:(NSNumber *)frame;
- (CGFloat)progressForFrame:(NSNumber *)frame;

@end

NS_ASSUME_NONNULL_END
