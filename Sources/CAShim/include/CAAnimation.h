/* CoreAnimation - CAAnimation.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CALayer.h"
#import "CAFrameRateRange.h"
#import <Foundation/NSObject.h>

@class NSArray, NSString, CAMediaTimingFunction, CAValueFunction;
@protocol CAAnimationDelegate;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NSString * CAAnimationCalculationMode NS_TYPED_ENUM  ;
typedef NSString * CAAnimationRotationMode NS_TYPED_ENUM  ;
typedef NSString * CATransitionType NS_TYPED_ENUM  ;
typedef NSString * CATransitionSubtype NS_TYPED_ENUM  ;

/** The base animation class. **/

 
@interface CAAnimation : NSObject
    <NSSecureCoding, NSCopying, CAMediaTiming, CAAction>
{
@private
  void *_attr;
  uint32_t _flags;
}

/* Creates a new animation object. */

+ (instancetype)animation;

/* Animations implement the same property model as defined by CALayer.
 * See CALayer.h for more details. */

+ (nullable id)defaultValueForKey:(NSString *)key;
- (BOOL)shouldArchiveValueForKey:(NSString *)key;

/* A timing function defining the pacing of the animation. Defaults to
 * nil indicating linear pacing. */

@property(nullable, strong) CAMediaTimingFunction *timingFunction;

/* The delegate of the animation. This object is retained for the
 * lifetime of the animation object. Defaults to nil. See below for the
 * supported delegate methods. */

@property(nullable, strong) id <CAAnimationDelegate> delegate;

/* When true, the animation is removed from the render tree once its
 * active duration has passed. Defaults to YES. */

@property(getter=isRemovedOnCompletion) BOOL removedOnCompletion;

/* Defines the range of desired frame rate in frames-per-second for this
   animation. The actual frame rate is dynamically adjusted to better align
   with other animation sources. */

@property CAFrameRateRange preferredFrameRateRange
     ;

@end

/* Delegate methods for CAAnimation. */

 
@protocol CAAnimationDelegate <NSObject>
@optional

/* Called when the animation begins its active duration. */

- (void)animationDidStart:(CAAnimation *)anim;

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end


/** Subclass for property-based animations. **/

 
@interface CAPropertyAnimation : CAAnimation

/* Creates a new animation object with its `keyPath' property set to
 * 'path'. */

+ (instancetype)animationWithKeyPath:(nullable NSString *)path;

/* The key-path describing the property to be animated. */

@property(nullable, copy) NSString *keyPath;

/* When true the value specified by the animation will be "added" to
 * the current presentation value of the property to produce the new
 * presentation value. The addition function is type-dependent, e.g.
 * for affine transforms the two matrices are concatenated. Defaults to
 * NO. */

@property(getter=isAdditive) BOOL additive;

/* The `cumulative' property affects how repeating animations produce
 * their result. If true then the current value of the animation is the
 * value at the end of the previous repeat cycle, plus the value of the
 * current repeat cycle. If false, the value is simply the value
 * calculated for the current repeat cycle. Defaults to NO. */

@property(getter=isCumulative) BOOL cumulative;

/* If non-nil a function that is applied to interpolated values
 * before they are set as the new presentation value of the animation's
 * target property. Defaults to nil. */

@property(nullable, strong) CAValueFunction *valueFunction;

@end


/** Subclass for basic (single-keyframe) animations. **/

 
@interface CABasicAnimation : CAPropertyAnimation

/* The objects defining the property values being interpolated between.
 * All are optional, and no more than two should be non-nil. The object
 * type should match the type of the property being animated (using the
 * standard rules described in CALayer.h). The supported modes of
 * animation are:
 *
 * - both `fromValue' and `toValue' non-nil. Interpolates between
 * `fromValue' and `toValue'.
 *
 * - `fromValue' and `byValue' non-nil. Interpolates between
 * `fromValue' and `fromValue' plus `byValue'.
 *
 * - `byValue' and `toValue' non-nil. Interpolates between `toValue'
 * minus `byValue' and `toValue'.
 *
 * - `fromValue' non-nil. Interpolates between `fromValue' and the
 * current presentation value of the property.
 *
 * - `toValue' non-nil. Interpolates between the layer's current value
 * of the property in the render tree and `toValue'.
 *
 * - `byValue' non-nil. Interpolates between the layer's current value
 * of the property in the render tree and that plus `byValue'. */

@property(nullable, strong) id fromValue;
@property(nullable, strong) id toValue;
@property(nullable, strong) id byValue;

@end


/** General keyframe animation class. **/

 
@interface CAKeyframeAnimation : CAPropertyAnimation

/* An array of objects providing the value of the animation function for
 * each keyframe. */

@property(nullable, copy) NSArray *values;

/* An optional path object defining the behavior of the animation
 * function. When non-nil overrides the `values' property. Each point
 * in the path except for `moveto' points defines a single keyframe for
 * the purpose of timing and interpolation. Defaults to nil. For
 * constant velocity animation along the path, `calculationMode' should
 * be set to `paced'. Upon assignment the path is copied. */

@property(nullable) CGPathRef path;

/* An optional array of `NSNumber' objects defining the pacing of the
 * animation. Each time corresponds to one value in the `values' array,
 * and defines when the value should be used in the animation function.
 * Each value in the array is a floating point number in the range
 * [0,1]. */

@property(nullable, copy) NSArray<NSNumber *> *keyTimes;

/* An optional array of CAMediaTimingFunction objects. If the `values' array
 * defines n keyframes, there should be n-1 objects in the
 * `timingFunctions' array. Each function describes the pacing of one
 * keyframe to keyframe segment. */

@property(nullable, copy) NSArray<CAMediaTimingFunction *> *timingFunctions;

/* The "calculation mode". Possible values are `discrete', `linear',
 * `paced', `cubic' and `cubicPaced'. Defaults to `linear'. When set to
 * `paced' or `cubicPaced' the `keyTimes' and `timingFunctions'
 * properties of the animation are ignored and calculated implicitly. */

@property(copy) CAAnimationCalculationMode calculationMode;

/* For animations with the cubic calculation modes, these properties
 * provide control over the interpolation scheme. Each keyframe may
 * have a tension, continuity and bias value associated with it, each
 * in the range [-1, 1] (this defines a Kochanek-Bartels spline, see
 * http://en.wikipedia.org/wiki/Kochanek-Bartels_spline).
 *
 * The tension value controls the "tightness" of the curve (positive
 * values are tighter, negative values are rounder). The continuity
 * value controls how segments are joined (positive values give sharp
 * corners, negative values give inverted corners). The bias value
 * defines where the curve occurs (positive values move the curve before
 * the control point, negative values move it after the control point).
 *
 * The first value in each array defines the behavior of the tangent to
 * the first control point, the second value controls the second
 * point's tangents, and so on. Any unspecified values default to zero
 * (giving a Catmull-Rom spline if all are unspecified). */

@property(nullable, copy) NSArray<NSNumber *> *tensionValues;
@property(nullable, copy) NSArray<NSNumber *> *continuityValues;
@property(nullable, copy) NSArray<NSNumber *> *biasValues;

/* Defines whether or objects animating along paths rotate to match the
 * path tangent. Possible values are `auto' and `autoReverse'. Defaults
 * to nil. The effect of setting this property to a non-nil value when
 * no path object is supplied is undefined. `autoReverse' rotates to
 * match the tangent plus 180 degrees. */

@property(nullable, copy) CAAnimationRotationMode rotationMode;

@end

/* `calculationMode' strings. */

CA_EXTERN CAAnimationCalculationMode const kCAAnimationLinear
     ;
CA_EXTERN CAAnimationCalculationMode const kCAAnimationDiscrete
     ;
CA_EXTERN CAAnimationCalculationMode const kCAAnimationPaced
     ;
CA_EXTERN CAAnimationCalculationMode const kCAAnimationCubic
     ;
CA_EXTERN CAAnimationCalculationMode const kCAAnimationCubicPaced
     ;

/* `rotationMode' strings. */

CA_EXTERN CAAnimationRotationMode const kCAAnimationRotateAuto
     ;
CA_EXTERN CAAnimationRotationMode const kCAAnimationRotateAutoReverse
     ;

/** Subclass for mass-spring animations. */

 
@interface CASpringAnimation : CABasicAnimation

/* The mass of the object attached to the end of the spring. Must be greater
   than 0. Defaults to one. */

@property CGFloat mass;

/* The spring stiffness coefficient. Must be greater than 0.
 * Defaults to 100. */

@property CGFloat stiffness;

/* The damping coefficient. Must be greater than or equal to 0.
 * Defaults to 10. */

@property CGFloat damping;

/* The initial velocity of the object attached to the spring. Defaults
 * to zero, which represents an unmoving object. Negative values
 * represent the object moving away from the spring attachment point,
 * positive values represent the object moving towards the spring
 * attachment point. */

@property CGFloat initialVelocity;

/* Whether true overdamping is allowed (otherwise it is treated as critically
 * damped). Defaults to false. */

@property BOOL allowsOverdamping
     ;

/* Returns the estimated duration required for the spring system to be
 * considered at rest. The duration is evaluated for the current animation
 * parameters. */

@property(readonly) CFTimeInterval settlingDuration;

/* Creates a spring animation with coefficients computed from the specified
 * perceptual duration and bounce. A spring animation created with this
 * initializer will have allowsOverdamping set to true (so will use overdamping
 * when a negative bounce is specified). */

- (instancetype)initWithPerceptualDuration:(CFTimeInterval)perceptualDuration
                    bounce:(CGFloat)bounce
     ;

/* The perceptual duration, which defines the pace of the spring. */

@property(readonly) CFTimeInterval perceptualDuration
     ;

/* How bouncy the spring is. A value of 0 indicates no bounces (a critically
 * damped spring), positive values indicate increasing amounts of bounce (with
 * typical values being between 0.0 and 1.0), and negative values indicate
 * overdamped springs (with typical values being between 0.0 and -1.0). */

@property(readonly) CGFloat bounce
     ;

@end

/** Transition animation subclass. **/

 
@interface CATransition : CAAnimation

/* The name of the transition. Current legal transition types include
 * `fade', `moveIn', `push' and `reveal'. Defaults to `fade'. */

@property(copy) CATransitionType type;

/* An optional subtype for the transition. E.g. used to specify the
 * transition direction for motion-based transitions, in which case
 * the legal values are `fromLeft', `fromRight', `fromTop' and
 * `fromBottom'. */

@property(nullable, copy) CATransitionSubtype subtype;

/* The amount of progress through to the transition at which to begin
 * and end execution. Legal values are numbers in the range [0,1].
 * `endProgress' must be greater than or equal to `startProgress'.
 * Default values are 0 and 1 respectively. */

@property float startProgress;
@property float endProgress;

/* An optional filter object implementing the transition. When set the
 * `type' and `subtype' properties are ignored. The filter must
 * implement `inputImage', `inputTargetImage' and `inputTime' input
 * keys, and the `outputImage' output key. Optionally it may support
 * the `inputExtent' key, which will be set to a rectangle describing
 * the region in which the transition should run. Defaults to nil. */

@property(nullable, strong) id filter
   ;

@end

/* Common transition types. */

CA_EXTERN CATransitionType const kCATransitionFade
     ;
CA_EXTERN CATransitionType const kCATransitionMoveIn
     ;
CA_EXTERN CATransitionType const kCATransitionPush
     ;
CA_EXTERN CATransitionType const kCATransitionReveal
     ;

/* Common transition subtypes. */

CA_EXTERN CATransitionSubtype const kCATransitionFromRight
     ;
CA_EXTERN CATransitionSubtype const kCATransitionFromLeft
     ;
CA_EXTERN CATransitionSubtype const kCATransitionFromTop
     ;
CA_EXTERN CATransitionSubtype const kCATransitionFromBottom
     ;


/** Animation subclass for grouped animations. **/

 
@interface CAAnimationGroup : CAAnimation

/* An array of CAAnimation objects. Each member of the array will run
 * concurrently in the time space of the parent animation using the
 * normal rules. */

@property(nullable, copy) NSArray<CAAnimation *> *animations;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
