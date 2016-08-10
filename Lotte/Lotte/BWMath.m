//
//  BWMath.m
//  Perfective
//
//  Created by Brandon Withrow on 5/11/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//
#import "BWMath.h"

CGPoint IntersectionOfPoints(CGPoint topLeft, CGPoint bottomRight, CGPoint topRight, CGPoint bottomLeft) {
  CGFloat d = (bottomRight.x - topLeft.x)*(bottomLeft.y - topRight.y) - (bottomRight.y - topLeft.y)*(bottomLeft.x - topRight.x);
  if (d == 0)
    return CGPointZero; // parallel lines
  CGFloat u = ((topRight.x - topLeft.x)*(bottomLeft.y - topRight.y) - (topRight.y - topLeft.y)*(bottomLeft.x - topRight.x))/d;
  CGFloat v = ((topRight.x - topLeft.x)*(bottomRight.y - topLeft.y) - (topRight.y - topLeft.y)*(bottomRight.x - topLeft.x))/d;
  if (u < 0.0 || u > 1.0)
    return CGPointZero; // intersection point not between topLeft and bottomRight
  if (v < 0.0 || v > 1.0)
    return CGPointZero; // intersection point not between topRight and bottomLeft
  CGPoint intersection;
  intersection.x = topLeft.x + u * (bottomRight.x - topLeft.x);
  intersection.y = topLeft.y + u * (bottomRight.y - topLeft.y);
  return intersection;
}

CGRect BoundingBoxForPoints(CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight) {
  CGRect boundingBox = CGRectZero;
  boundingBox.origin.x = topLeft.x < bottomLeft.x ? topLeft.x : bottomLeft.x;
  boundingBox.origin.y = topLeft.y < topRight.y ? topLeft.y : topRight.y;
  
  boundingBox.size.width  = (topRight.x > bottomRight.x ? topRight.x : bottomRight.x) - boundingBox.origin.x;
  boundingBox.size.height  = (bottomLeft.y > bottomRight.y ? bottomLeft.y : bottomRight.y) - boundingBox.origin.y;
  
  return boundingBox;
}

CGFloat sqr(CGFloat num) {
  return pow(num, 2);
}

CGFloat RadiansToDegrees(CGFloat radians) {
  return ( ( radians ) * ( 180.0 / M_PI ) );
}

CGFloat DegreesToRadians(CGFloat degrees) {
  return  ( ( degrees ) / 180.0 * M_PI );
}

CGPoint PointOnCircleAtAngle(CGFloat circleRadius, CGPoint circleCenter, CGFloat angleInDegrees) {
//  x = cx + r * cos(a)
//  y = cy + r * sin(a)
//x = cx + (r * cos(a)) and y = cy + (r * sin(a))
  CGFloat radians = DegreesToRadians(angleInDegrees);
  return CGPointMake(circleCenter.x + (circleRadius * cos(radians)),
                     circleCenter.y + (circleRadius * sin(radians)));
}

CGFloat RemapValue(CGFloat value, CGFloat low1, CGFloat high1, CGFloat low2, CGFloat high2 ) {
  return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

CGFloat LoopFloat(CGFloat value, CGFloat min, CGFloat max) {
  CGFloat loopedValue;
  
  // Get to base zero.
  CGFloat offsetMax = max - min;
  CGFloat offsetValue  = value - min;
  
  CGFloat valueDiffFactor = floor(offsetValue / offsetMax);
  CGFloat baseZeroLooped = offsetValue - (valueDiffFactor * offsetMax);
  loopedValue = baseZeroLooped + min;
  
  return loopedValue;
}
