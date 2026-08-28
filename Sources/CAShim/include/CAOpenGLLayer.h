/* CoreAnimation - CAOpenGLLayer.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#if __has_include(<OpenGL/OpenGL.h>)

#import "CALayer.h"
#import <CoreVideo/CVBase.h>
#import <OpenGL/OpenGL.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

#ifndef GL_SILENCE_DEPRECATION

#else

#endif

@interface CAOpenGLLayer : CALayer
{
@private
  struct CAOpenGLLayerPrivate *_glPriv;
}

/* When false the contents of the layer is only updated in response to
 * -setNeedsDisplay messages. When true the layer is asked to redraw
 * periodically with timestamps matching the display update frequency.
 * The default value is NO. */

@property(getter=isAsynchronous) BOOL asynchronous;

/* Called before attempting to render the frame for layer time 't'.
 * When non-null 'ts' describes the display timestamp associated with
 * layer time 't'. If the method returns false, the frame is skipped. The
 * default implementation always returns YES. */

- (BOOL)canDrawInCGLContext:(CGLContextObj)ctx
    pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t
    displayTime:(nullable const CVTimeStamp *)ts;

/* Called when a new frame needs to be generated for layer time 't'.
 * 'ctx' is attached to the rendering destination. It's state is
 * otherwise undefined. When non-null 'ts'  describes the display
 * timestamp associated with layer time 't'. Subclasses should call
 * the superclass implementation of the method to flush the context
 * after rendering. */

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf
    forLayerTime:(CFTimeInterval)t displayTime:(nullable const CVTimeStamp *)ts;

/* This method will be called by the CAOpenGLLayer implementation when
 * a pixel format object is needed for the layer. Should return an
 * OpenGL pixel format suitable for rendering to the set of displays
 * defined by the display mask 'mask'. The default implementation
 * returns a 32bpp fixed point pixel format, with NoRecovery and
 * Accelerated flags set. */

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask;

/* Called when the OpenGL pixel format 'pf' that was previously
 * returned from -copyCGLPixelFormatForDisplayMask: is no longer
 * needed. */

- (void)releaseCGLPixelFormat:(CGLPixelFormatObj)pf;

/* Called by the CAOpenGLLayer implementation when a rendering context
 * is needed by the layer. Should return an OpenGL context with
 * renderers from pixel format 'pf'. The default implementation
 * allocates a new context with a null share context. */

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pf;

/* Called when the OpenGL context 'ctx' that was previously returned
 * from -copyCGLContextForPixelFormat: is no longer needed. */

- (void)releaseCGLContext:(CGLContextObj)ctx;

/* The colorspace of the rendered frames. If nil, no colormatching occurs.
 * If non-nil, the rendered content will be colormatched to the colorspace of
 * the context containing this layer (typically the display's colorspace). */

@property (nullable) CGColorSpaceRef colorspace;

/* If any rendering context on the screen has this enabled, all content will be
 * clamped to its NSScreen’s maximumExtendedDynamicRangeColorComponentValue
 * rather than 1.0. The default is NO.  */

@property BOOL wantsExtendedDynamicRangeContent
  ;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<OpenGL/OpenGL.h>) */

#endif /* __OBJC__ */
