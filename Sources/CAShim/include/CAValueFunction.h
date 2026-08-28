/* CoreAnimation - CAValueFunction.h

   Copyright (c) 2008-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CABase.h"
#import <Foundation/NSObject.h>

typedef NSString * CAValueFunctionName NS_TYPED_ENUM  ;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

 
@interface CAValueFunction : NSObject <NSSecureCoding>
{
@protected
  NSString *_string;
  void *_impl;
}

+ (nullable instancetype)functionWithName:(CAValueFunctionName)name;

@property(readonly) CAValueFunctionName name;

@end

/** Value function names. **/

/* The `rotateX', `rotateY', `rotateZ' functions take a single input
 * value in radians, and construct a 4x4 matrix representing the
 * corresponding rotation matrix. */

CA_EXTERN CAValueFunctionName const kCAValueFunctionRotateX
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionRotateY
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionRotateZ
     ;

/* The `scale' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

CA_EXTERN CAValueFunctionName const kCAValueFunctionScale
     ;

/* The `scaleX', `scaleY', `scaleZ' functions take a single input value
 * and construct a 4x4 matrix representing the corresponding scaling
 * matrix. */

CA_EXTERN CAValueFunctionName const kCAValueFunctionScaleX
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionScaleY
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionScaleZ
     ;

/* The `translate' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

CA_EXTERN CAValueFunctionName const kCAValueFunctionTranslate
     ;

/* The `translateX', `translateY', `translateZ' functions take a single
 * input value and construct a 4x4 matrix representing the corresponding
 * translation matrix. */

CA_EXTERN CAValueFunctionName const kCAValueFunctionTranslateX
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionTranslateY
     ;
CA_EXTERN CAValueFunctionName const kCAValueFunctionTranslateZ
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
