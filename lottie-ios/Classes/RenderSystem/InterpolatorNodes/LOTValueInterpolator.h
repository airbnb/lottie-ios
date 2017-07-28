//
//  LOTValueInterpolator.h
//  Pods
//
//  Created by brandon_withrow on 7/10/17.
//
//

#import <Foundation/Foundation.h>
#import "LOTKeyframe.h"

@interface LOTValueInterpolator : NSObject

- (instancetype)initWithKeyframes:(NSArray <LOTKeyframe *> *)keyframes;

@property (nonatomic, weak) LOTKeyframe *leadingKeyframe;
@property (nonatomic, weak) LOTKeyframe *trailingKeyframe;

- (BOOL)hasUpdateForFrame:(NSNumber *)frame;
- (CGFloat)progressForFrame:(NSNumber *)frame;

@end


/*

 What do we need?
 We need a keyframe interpolator for color, numbers, scale, shape, points and bounds
 
 How will this be done?
 Each thing will need a list of keyframe objects
 the keyframe object will hold its time, its value, its type, and an interpolation curve (type?)
 
 A LOTRenderNode will have its time set.
 It needs to know if there are changes for timevalue
 if there are
 It will ask its keyframeinterpolator for its value at time
 
 at this point the keyframe interpolator will
 find the keyframe span that fits the given time
 it will interpolate its from to with the given time
 it will return the value
 
 So what parts of the machine are there?
 
 LOTRenderNode - Handles the necessary geometry and render information
  The geometry nodes will construct geometry OUTPUT from multiple sources of keyframe data
 
 LOTAnimatablePrimitives - Holds all keyframe information for a given channel
 
 
 
 
 Interpolator - Has in time, out time, in value, out value, in tangent, out tangent
 Returns value for time
 
 
 What to do about bezier paths?
 They need ot be created, interpolated, trimmed, and merged.
 The lets minimize the times we actually create bezier paths, that seems expensive.
 they will be created at runtime. Lets try that.
 
*/
