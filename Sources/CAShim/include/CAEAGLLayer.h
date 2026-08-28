/* CoreAnimation - CAEAGLLayer.h

   Copyright (c) 2007-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#if __has_include(<OpenGLES/EAGLDrawable.h>)

#import "CALayer.h"
#import <OpenGLES/EAGLDrawable.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

/* CAEAGLLayer is a layer that implements the EAGLDrawable protocol,
 * allowing it to be used as an OpenGLES render target. Use the
 * `drawableProperties' property defined by the protocol to configure
 * the created surface. */

#ifndef GLES_SILENCE_DEPRECATION


#else
 
#endif
@interface CAEAGLLayer : CALayer <EAGLDrawable>
{
@private
  struct _CAEAGLNativeWindow *_win;
}

/* When false (the default value) changes to the layer's render buffer
 * appear on-screen asynchronously to normal layer updates. When true,
 * changes to the GLES content are sent to the screen via the standard
 * CATransaction mechanisms. */

@property BOOL presentsWithTransaction  ;

/* Note: the default value of the `opaque' property in this class is true,
 * not false as in CALayer. */

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<OpenGLES/EAGLDrawable.h>) */

#endif /* __OBJC__ */
