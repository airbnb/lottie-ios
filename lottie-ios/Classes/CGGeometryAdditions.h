
#import <UIKit/UIKit.h>
#import <GLKit/GLKMathTypes.h>
#import <GLKit/GLKit.h>
//
// Core Graphics Geometry Additions
//

extern const CGSize CGSizeMax;

CGRect BBRectIntegral(CGRect rect);

// Centering

// Returns a rectangle of the given size, centered at a point
CGRect CGRectCenteredAtPoint(CGPoint center, CGSize size, BOOL integral);

// Returns the center point of a CGRect
CGPoint CGRectGetCenterPoint(CGRect rect);

// Insetting

// Inset the rectangle on a single edge
CGRect CGRectInsetLeft(CGRect rect, CGFloat inset);
CGRect CGRectInsetRight(CGRect rect, CGFloat inset);
CGRect CGRectInsetTop(CGRect rect, CGFloat inset);
CGRect CGRectInsetBottom(CGRect rect, CGFloat inset);

// Inset the rectangle on two edges
CGRect CGRectInsetHorizontal(CGRect rect, CGFloat leftInset, CGFloat rightInset);
CGRect CGRectInsetVertical(CGRect rect, CGFloat topInset, CGFloat bottomInset);

// Inset the rectangle on all edges
CGRect CGRectInsetAll(CGRect rect, CGFloat leftInset, CGFloat rightInset, CGFloat topInset, CGFloat bottomInset);

// Expand a size or rectangle by edge insets
CGFloat UIEdgeInsetsExpandWidth(CGFloat width, UIEdgeInsets insets);
CGFloat UIEdgeInsetsExpandHeight(CGFloat height, UIEdgeInsets insets);
CGSize UIEdgeInsetsContractSize(CGSize size, UIEdgeInsets insets);

CGSize UIEdgeInsetsContractWidth(CGSize size, UIEdgeInsets insets);
CGSize UIEdgeInsetsContractHeight(CGSize size, UIEdgeInsets insets);
CGSize UIEdgeInsetsExpandSize(CGSize size, UIEdgeInsets insets);

CGRect UIEdgeInsetsExpandRect(CGRect rect, UIEdgeInsets insets);

// Framing

// Returns a rectangle of size framed in the center of the given rectangle
CGRect CGRectFramedCenteredInRect(CGRect rect, CGSize size, BOOL integral);

// Returns a rectangle of size framed in the given rectangle and inset
CGRect CGRectFramedLeftInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral);
CGRect CGRectFramedRightInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral);
CGRect CGRectFramedTopInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral);
CGRect CGRectFramedBottomInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral);

CGRect CGRectFramedTopLeftInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral);
CGRect CGRectFramedTopRightInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral);
CGRect CGRectFramedBottomLeftInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral);
CGRect CGRectFramedBottomRightInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral);

// Divides a rect into sections and returns the section at specified index

CGRect CGRectDividedSection(CGRect rect, NSInteger sections, NSInteger index, CGRectEdge fromEdge);

// Returns a rectangle of size attached to the given rectangle
CGRect CGRectAttachedLeftToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral);
CGRect CGRectAttachedRightToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral);
CGRect CGRectAttachedTopToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral);
CGRect CGRectAttachedBottomToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral);

CGRect CGRectAttachedBottomLeftToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral);
CGRect CGRectAttachedBottomRightToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral);
CGRect CGRectAttachedTopRightToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral);
CGRect CGRectAttachedTopLeftToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral);

// Combining
// Adds all values of the 2nd rect to the first rect
CGRect CGRectAddRect(CGRect rect, CGRect other);
CGRect CGRectAddPoint(CGRect rect, CGPoint point);
CGRect CGRectAddSize(CGRect rect, CGSize size);
CGRect CGRectBounded(CGRect rect);

CGPoint CGPointAddedToPoint(CGPoint point1, CGPoint point2);

/**
* update the height property of a rect
* @return new rectangle with updated height
* */
CGRect CGRectSetHeight(CGRect rect, CGFloat height);

CGFloat CGPointDistanceFromPoint(CGPoint point1, CGPoint point2);
CGFloat DegreestoRadians(CGFloat degrees);

GLKMatrix4 GLKMatrix4FromCATransform(CATransform3D xform);

CATransform3D CATransform3DFromGLKMatrix4(GLKMatrix4 xform);

CATransform3D CATransform3DSlerpToTransform(CATransform3D fromXorm, CATransform3D toXform, CGFloat amount );

CGFloat DegreesToRadians(CGFloat degrees);

CGFloat RemapValue(CGFloat value, CGFloat low1, CGFloat high1, CGFloat low2, CGFloat high2 );
CGPoint CGPointByLerpingPoints(CGPoint point1, CGPoint point2, CGFloat value);
