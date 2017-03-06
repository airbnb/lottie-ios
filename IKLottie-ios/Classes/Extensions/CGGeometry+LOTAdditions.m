
#import "CGGeometry+LOTAdditions.h"

const CGSize CGSizeMax = {CGFLOAT_MAX, CGFLOAT_MAX};
const NSTimeInterval LOT_singleFrameTimeValue = 1.0 / 60.0;
//
// Core Graphics Geometry Additions
//

// CGRectIntegral returns a rectangle with the smallest integer values for its origin and size that contains the source rectangle.
// For a rect with .origin={5, 5.5}, .size=(10, 10), it will return .origin={5,5}, .size={10, 11};
// LOT_RectIntegral will return {5,5}, {10, 10}.
CGRect LOT_RectIntegral(CGRect rect) {
  rect.origin = CGPointMake(rintf(rect.origin.x), rintf(rect.origin.y));
  rect.size = CGSizeMake(ceilf(rect.size.width), ceil(rect.size.height));
  return rect;
}

//
// Centering

// Returns a rectangle of the given size, centered at a point

CGRect LOT_RectCenteredAtPoint(CGPoint center, CGSize size, BOOL integral) {
  CGRect result;
  result.origin.x = center.x - 0.5f * size.width;
  result.origin.y = center.y - 0.5f * size.height;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

// Returns the center point of a CGRect
CGPoint LOT_RectGetCenterPoint(CGRect rect) {
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

//
// Insetting

// Inset the rectangle on a single edge

CGRect LOT_RectInsetLeft(CGRect rect, CGFloat inset) {
  rect.origin.x += inset;
  rect.size.width -= inset;
  return rect;
}

CGRect LOT_RectInsetRight(CGRect rect, CGFloat inset) {
  rect.size.width -= inset;
  return rect;
}

CGRect LOT_RectInsetTop(CGRect rect, CGFloat inset) {
  rect.origin.y += inset;
  rect.size.height -= inset;
  return rect;
}

CGRect LOT_RectInsetBottom(CGRect rect, CGFloat inset) {
  rect.size.height -= inset;
  return rect;
}

// Inset the rectangle on two edges

CGRect LOT_RectInsetHorizontal(CGRect rect, CGFloat leftInset, CGFloat rightInset) {
  rect.origin.x += leftInset;
  rect.size.width -= (leftInset + rightInset);
  return rect;
}

CGRect LOT_RectInsetVertical(CGRect rect, CGFloat topInset, CGFloat bottomInset) {
  rect.origin.y += topInset;
  rect.size.height -= (topInset + bottomInset);
  return rect;
}

// Inset the rectangle on all edges

CGRect LOT_RectInsetAll(CGRect rect, CGFloat leftInset, CGFloat rightInset, CGFloat topInset, CGFloat bottomInset) {
  rect.origin.x += leftInset;
  rect.origin.y += topInset;
  rect.size.width -= (leftInset + rightInset);
  rect.size.height -= (topInset + bottomInset);
  return rect;
}

//
// Framing

// Returns a rectangle of size framed in the center of the given rectangle

CGRect LOT_RectFramedCenteredInRect(CGRect rect, CGSize size, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rintf(0.5f * (rect.size.width - size.width));
  result.origin.y = rect.origin.y + rintf(0.5f * (rect.size.height - size.height));
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

// Returns a rectangle of size framed in the given rectangle and inset

CGRect LOT_RectFramedLeftInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + inset;
  result.origin.y = rect.origin.y + rintf(0.5f * (rect.size.height - size.height));
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedRightInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width - size.width - inset;
  result.origin.y = rect.origin.y + rintf(0.5f * (rect.size.height - size.height));
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedTopInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rintf(0.5f * (rect.size.width - size.width));
  result.origin.y = rect.origin.y + inset;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedBottomInRect(CGRect rect, CGSize size, CGFloat inset, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rintf(0.5f * (rect.size.width - size.width));
  result.origin.y = rect.origin.y + rect.size.height - size.height - inset;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedTopLeftInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + insetWidth;
  result.origin.y = rect.origin.y + insetHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedTopRightInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width - size.width - insetWidth;
  result.origin.y = rect.origin.y + insetHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedBottomLeftInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + insetWidth;
  result.origin.y = rect.origin.y + rect.size.height - size.height - insetHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectFramedBottomRightInRect(CGRect rect, CGSize size, CGFloat insetWidth, CGFloat insetHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width - size.width - insetWidth;
  result.origin.y = rect.origin.y + rect.size.height - size.height - insetHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

// Returns a rectangle of size attached to the given rectangle

CGRect LOT_RectAttachedLeftToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x - size.width - margin;
  result.origin.y = rect.origin.y + rintf(0.5f * (rect.size.height - size.height));
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedRightToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width + margin;
  result.origin.y = rect.origin.y + rintf(0.5f * (rect.size.height - size.height));
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedTopToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rintf(0.5f * (rect.size.width - size.width));
  result.origin.y = rect.origin.y - size.height - margin;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedTopLeftToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + marginWidth;
  result.origin.y = rect.origin.y - size.height - marginHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedTopRightToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width - size.width - marginWidth;
  result.origin.y = rect.origin.y - rect.size.height - marginHeight;
  result.size = size;

  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedBottomToRect(CGRect rect, CGSize size, CGFloat margin, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rintf(0.5f * (rect.size.width - size.width));
  result.origin.y = rect.origin.y + rect.size.height + margin;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedBottomLeftToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + marginWidth;
  result.origin.y = rect.origin.y + rect.size.height + marginHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

CGRect LOT_RectAttachedBottomRightToRect(CGRect rect, CGSize size, CGFloat marginWidth, CGFloat marginHeight, BOOL integral) {
  CGRect result;
  result.origin.x = rect.origin.x + rect.size.width - size.width - marginWidth;
  result.origin.y = rect.origin.y + rect.size.height + marginHeight;
  result.size = size;
  
  if (integral) { result = LOT_RectIntegral(result); }
  return result;
}

// Divides a rect into sections and returns the section at specified index

CGRect LOT_RectDividedSection(CGRect rect, NSInteger sections, NSInteger index, CGRectEdge fromEdge) {
  if (sections == 0) {
    return CGRectZero;
  }
  CGRect r = rect;
  if (fromEdge == CGRectMaxXEdge || fromEdge == CGRectMinXEdge) {
    r.size.width = rect.size.width / sections;
    r.origin.x += r.size.width * index;
  } else {
    r.size.height = rect.size.height / sections;
    r.origin.y += r.size.height * index;
  }
  return r;
}


CGRect LOT_RectAddRect(CGRect rect, CGRect other) {
  return CGRectMake(rect.origin.x + other.origin.x, rect.origin.y + other.origin.y,
                    rect.size.width + other.size.width, rect.size.height + other.size.height);
}

CGRect LOT_RectAddPoint(CGRect rect, CGPoint point) {
  return CGRectMake(rect.origin.x + point.x, rect.origin.y + point.y,
                    rect.size.width, rect.size.height);
}

CGRect LOT_RectAddSize(CGRect rect, CGSize size) {
  return CGRectMake(rect.origin.x, rect.origin.y,
                    rect.size.width + size.width, rect.size.height + size.height);
}

CGRect LOT_RectBounded(CGRect rect) {
  CGRect returnRect = rect;
  returnRect.origin = CGPointZero;
  return returnRect;
}

CGPoint LOT_PointAddedToPoint(CGPoint point1, CGPoint point2) {
  CGPoint returnPoint = point1;
  returnPoint.x += point2.x;
  returnPoint.y += point2.y;
  return returnPoint;
}

CGRect LOT_RectSetHeight(CGRect rect, CGFloat height) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height);
}

CGFloat LOT_DegreesToRadians(CGFloat degrees) {
  return degrees * M_PI / 180;
}

GLKMatrix4 LOT_GLKMatrix4FromCATransform(CATransform3D xform) {
  return GLKMatrix4Make(xform.m11, xform.m12, xform.m13, xform.m14,
                        xform.m21, xform.m22, xform.m23, xform.m24,
                        xform.m31, xform.m32, xform.m33, xform.m34,
                        xform.m41, xform.m42, xform.m43, xform.m44);
}

CATransform3D LOT_CATransform3DFromGLKMatrix4(GLKMatrix4 xform) {
  CATransform3D newXform;
  newXform.m11 = xform.m00;
  newXform.m12 = xform.m01;
  newXform.m13 = xform.m02;
  newXform.m14 = xform.m03;
  newXform.m21 = xform.m10;
  newXform.m22 = xform.m11;
  newXform.m23 = xform.m12;
  newXform.m24 = xform.m13;
  newXform.m31 = xform.m20;
  newXform.m32 = xform.m21;
  newXform.m33 = xform.m22;
  newXform.m34 = xform.m23;
  newXform.m41 = xform.m30;
  newXform.m42 = xform.m31;
  newXform.m43 = xform.m32;
  newXform.m44 = xform.m33;
  return newXform;
}

CATransform3D LOT_CATransform3DSlerpToTransform(CATransform3D fromXorm, CATransform3D toXform, CGFloat amount ){
  //  amount = MIN(MAX(0, amount), 1);
  if (amount == 0 || amount == 1) {
    return amount == 0 ? fromXorm : toXform;
  }
  GLKMatrix4 xform1 = LOT_GLKMatrix4FromCATransform(fromXorm);
  GLKMatrix4 xform2 = LOT_GLKMatrix4FromCATransform(toXform);
  GLKQuaternion q1 = GLKQuaternionMakeWithMatrix4(xform1);
  GLKQuaternion q2 = GLKQuaternionMakeWithMatrix4(xform2);
  GLKQuaternion r1 = GLKQuaternionSlerp(q1, q2, amount);
  GLKVector4 t1 = GLKVector4Make(xform1.m30, xform1.m31, xform1.m32, xform1.m33);
  GLKVector4 t2 = GLKVector4Make(xform2.m30, xform2.m31, xform2.m32, xform2.m33);
  GLKVector4 r2 = GLKVector4Lerp(t1, t2, amount);
  
  GLKMatrix4 rX = GLKMatrix4MakeWithQuaternion(r1);
  rX.m30 = r2.x;
  rX.m31 = r2.y;
  rX.m32 = r2.z;
  return LOT_CATransform3DFromGLKMatrix4(rX);
}

CGFloat LOT_PointDistanceFromPoint(CGPoint point1, CGPoint point2) {
  CGFloat xDist = (point2.x - point1.x);
  CGFloat yDist = (point2.y - point1.y);
  CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
  return distance;
}

CGFloat LOT_RemapValue(CGFloat value, CGFloat low1, CGFloat high1, CGFloat low2, CGFloat high2 ) {
  return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

CGPoint LOT_PointByLerpingPoints(CGPoint point1, CGPoint point2, CGFloat value) {
  CGFloat xDiff = point2.x - point1.x;
  CGFloat yDiff = point2.y - point1.y;
  CGPoint transposed = CGPointMake(fabs(xDiff), fabs(yDiff));
  CGPoint returnPoint;
  if (xDiff == 0 || yDiff == 0) {
    returnPoint.x = xDiff == 0 ? point1.x : LOT_RemapValue(value, 0, 1, point1.x, point2.x);
    returnPoint.y = yDiff == 0 ? point1.y : LOT_RemapValue(value, 0, 1, point1.y, point2.y);
  } else {
    CGFloat rx = transposed.x / transposed.y;
    CGFloat yLerp = LOT_RemapValue(value, 0, 1, 0, transposed.y);
    CGFloat xLerp = yLerp * rx;
    CGPoint interpolatedPoint = CGPointMake(point2.x < point1.x ? xLerp * -1 : xLerp,
                                            point2.y < point1.y ? yLerp * -1 : yLerp);
    returnPoint = LOT_PointAddedToPoint(point1, interpolatedPoint);
  }
  return returnPoint;
}
