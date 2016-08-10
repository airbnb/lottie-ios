//
//  BWMath.h
//  Perfective
//
//  Created by Brandon Withrow on 5/11/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//
#import <GLKit/GLKit.h>

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);
CGPoint IntersectionOfPoints(CGPoint topLeft, CGPoint bottomRight, CGPoint topRight, CGPoint bottomLeft);
CGRect BoundingBoxForPoints(CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);

CGFloat RadiansToDegrees(CGFloat radians);
CGFloat DegreesToRadians(CGFloat degrees);
CGPoint PointOnCircleAtAngle(CGFloat circleRadius, CGPoint circleCenter, CGFloat angleInDegrees);

CGFloat RemapValue(CGFloat value, CGFloat low1, CGFloat high1, CGFloat low2, CGFloat high2 );

CGFloat LoopFloat(CGFloat value, CGFloat min, CGFloat max);
