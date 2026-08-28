/* CoreAnimation - CAScrollLayer.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CALayer.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NSString * CAScrollLayerScrollMode NS_TYPED_ENUM  ;

 
@interface CAScrollLayer : CALayer

/* Changes the origin of the layer to point 'p'. */

- (void)scrollToPoint:(CGPoint)p;

/* Scroll the contents of the layer to ensure that rect 'r' is visible. */

- (void)scrollToRect:(CGRect)r;

/* Defines the axes in which the layer may be scrolled. Possible values
 * are `none', `vertically', `horizontally' or `both' (the default). */

@property(copy) CAScrollLayerScrollMode scrollMode;

@end

@interface CALayer (CALayerScrolling)

/* These methods search for the closest ancestor CAScrollLayer of the *
 * receiver, and then call either -scrollToPoint: or -scrollToRect: on
 * that layer with the specified geometry converted from the coordinate
 * space of the receiver to that of the found scroll layer. */

- (void)scrollPoint:(CGPoint)p;

- (void)scrollRectToVisible:(CGRect)r;

/* Returns the visible region of the receiver, in its own coordinate
 * space. The visible region is the area not clipped by the containing
 * scroll layer. */

@property(readonly) CGRect visibleRect;

@end

/* `scrollMode' values. */

CA_EXTERN CAScrollLayerScrollMode const kCAScrollNone
     ;
CA_EXTERN CAScrollLayerScrollMode const kCAScrollVertically
     ;
CA_EXTERN CAScrollLayerScrollMode const kCAScrollHorizontally
     ;
CA_EXTERN CAScrollLayerScrollMode const kCAScrollBoth
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
