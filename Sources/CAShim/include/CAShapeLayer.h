/* CoreAnimation - CAShapeLayer.h

   Copyright (c) 2008-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CALayer.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NSString * CAShapeLayerFillRule NS_TYPED_ENUM  ;
typedef NSString * CAShapeLayerLineJoin NS_TYPED_ENUM  ;
typedef NSString * CAShapeLayerLineCap NS_TYPED_ENUM  ;

/* The shape layer draws a cubic Bezier spline in its coordinate space.
 *
 * The spline is described using a CGPath object and may have both fill
 * and stroke components (in which case the stroke is composited over
 * the fill). The shape as a whole is composited between the layer's
 * contents and its first sublayer.
 *
 * The path object may be animated using any of the concrete subclasses
 * of CAPropertyAnimation. Paths will interpolate as a linear blend of
 * the "on-line" points; "off-line" points may be interpolated
 * non-linearly (e.g. to preserve continuity of the curve's
 * derivative). If the two paths have a different number of control
 * points or segments the results are undefined.
 *
 * The shape will be drawn antialiased, and whenever possible it will
 * be mapped into screen space before being rasterized to preserve
 * resolution independence. (However, certain kinds of image processing
 * operations, e.g. CoreImage filters, applied to the layer or its
 * ancestors may force rasterization in a local coordinate space.)
 *
 * Note: rasterization may favor speed over accuracy, e.g. pixels with
 * multiple intersecting path segments may not give exact results. */

 
@interface CAShapeLayer : CALayer

/* The path defining the shape to be rendered. If the path extends
 * outside the layer bounds it will not automatically be clipped to the
 * layer, only if the normal layer masking rules cause that. Upon
 * assignment the path is copied. Defaults to null. Animatable.
 * (Note that although the path property is animatable, no implicit
 * animation will be created when the property is changed.) */

@property(nullable) CGPathRef path;

/* The color to fill the path, or nil for no fill. Defaults to opaque
 * black. Animatable. */

@property(nullable) CGColorRef fillColor;

/* The fill rule used when filling the path. Options are `non-zero' and
 * `even-odd'. Defaults to `non-zero'. */

@property(copy) CAShapeLayerFillRule fillRule;

/* The color to fill the path's stroked outline, or nil for no stroking.
 * Defaults to nil. Animatable. */

@property(nullable) CGColorRef strokeColor;

/* These values define the subregion of the path used to draw the
 * stroked outline. The values must be in the range [0,1] with zero
 * representing the start of the path and one the end. Values in
 * between zero and one are interpolated linearly along the path
 * length. strokeStart defaults to zero and strokeEnd to one. Both are
 * animatable. */

@property CGFloat strokeStart;
@property CGFloat strokeEnd;

/* The line width used when stroking the path. Defaults to one.
 * Animatable. */

@property CGFloat lineWidth;

/* The miter limit used when stroking the path. Defaults to ten.
 * Animatable. */

@property CGFloat miterLimit;

/* The cap style used when stroking the path. Options are `butt', `round'
 * and `square'. Defaults to `butt'. */

@property(copy) CAShapeLayerLineCap lineCap;

/* The join style used when stroking the path. Options are `miter', `round'
 * and `bevel'. Defaults to `miter'. */

@property(copy) CAShapeLayerLineJoin lineJoin;

/* The phase of the dashing pattern applied when creating the stroke.
 * Defaults to zero. Animatable. */

@property CGFloat lineDashPhase;

/* The dash pattern (an array of NSNumbers) applied when creating the
 * stroked version of the path. Defaults to nil. */

@property(nullable, copy) NSArray<NSNumber *> *lineDashPattern;

@end

/* `fillRule' values. */

CA_EXTERN CAShapeLayerFillRule const kCAFillRuleNonZero
     ;
CA_EXTERN CAShapeLayerFillRule const kCAFillRuleEvenOdd
     ;

/* `lineJoin' values. */

CA_EXTERN CAShapeLayerLineJoin const kCALineJoinMiter
     ;
CA_EXTERN CAShapeLayerLineJoin const kCALineJoinRound
     ;
CA_EXTERN CAShapeLayerLineJoin const kCALineJoinBevel
     ;

/* `lineCap' values. */

CA_EXTERN CAShapeLayerLineCap const kCALineCapButt
     ;
CA_EXTERN CAShapeLayerLineCap const kCALineCapRound
     ;
CA_EXTERN CAShapeLayerLineCap const kCALineCapSquare
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
