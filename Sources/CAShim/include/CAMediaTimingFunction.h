/* CoreAnimation - CAMediaTimingFunction.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CAMediaTiming.h"
#import <Foundation/NSObject.h>

@class NSArray, NSString;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NSString * CAMediaTimingFunctionName NS_TYPED_ENUM  ;

/* Represents one segment of a function describing a timing curve. The
 * function maps an input time normalized to the range [0,1] to an
 * output time also in the range [0,1]. E.g. these functions are used
 * to define the pacing of an animation over its duration (or over the
 * duration of one keyframe). */

 
@interface CAMediaTimingFunction : NSObject <NSSecureCoding>
{
@private
  struct CAMediaTimingFunctionPrivate *_priv;
}

/* A convenience method for creating common timing functions. The
 * currently supported names are `linear', `easeIn', `easeOut' and
 * `easeInEaseOut' and `default' (the curve used by implicit animations
 * created by Core Animation). */

+ (instancetype)functionWithName:(CAMediaTimingFunctionName)name;

/* Creates a timing function modelled on a cubic Bezier curve. The end
 * points of the curve are at (0,0) and (1,1), the two points 'c1' and
 * 'c2' defined by the class instance are the control points. Thus the
 * points defining the Bezier curve are: '[(0,0), c1, c2, (1,1)]' */

+ (instancetype)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;

- (instancetype)initWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;

/* 'idx' is a value from 0 to 3 inclusive. */

- (void)getControlPointAtIndex:(size_t)idx values:(float[_Nonnull 2])ptr;

@end

/** Timing function names. **/

CA_EXTERN CAMediaTimingFunctionName const kCAMediaTimingFunctionLinear
     ;
CA_EXTERN CAMediaTimingFunctionName const kCAMediaTimingFunctionEaseIn
     ;
CA_EXTERN CAMediaTimingFunctionName const kCAMediaTimingFunctionEaseOut
     ;
CA_EXTERN CAMediaTimingFunctionName const kCAMediaTimingFunctionEaseInEaseOut
     ;
CA_EXTERN CAMediaTimingFunctionName const kCAMediaTimingFunctionDefault
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
