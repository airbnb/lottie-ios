//
//  BWMath.h
//  Perfective
//
//  Created by Brandon Withrow on 5/11/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//
#import <GLKit/GLKit.h>

GLKMatrix3 General2dProjection(CGFloat x1s, CGFloat y1s, CGFloat x1d, CGFloat y1d,
                               CGFloat x2s, CGFloat y2s, CGFloat x2d, CGFloat y2d,
                               CGFloat x3s, CGFloat y3s, CGFloat x3d, CGFloat y3d,
                               CGFloat x4s, CGFloat y4s, CGFloat x4d, CGFloat y4d);
GLKMatrix3 AdjugateOfMatrix(GLKMatrix3 m);
GLKMatrix3 PositiveMultiplyMatrix(GLKMatrix3 a, GLKMatrix3 b);
GLKMatrix3 BasisToPoints(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat x3, CGFloat y3, CGFloat x4, CGFloat y4);

GLKMatrix4 HomographicMatrix(CGFloat width, CGFloat height, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);
GLKMatrix4 TransHomographicMatrix(CGFloat width, CGFloat height, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);
CGPoint IntersectionOfPoints(CGPoint topLeft, CGPoint bottomRight, CGPoint topRight, CGPoint bottomLeft);
GLKVector4 QuadrilateralQForPoints(CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);
CGRect BoundingBoxForPoints(CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);

GLKMatrix4 GLKMatrix4Slerp(GLKMatrix4 from, GLKMatrix4 to, CGFloat amount);
CGFloat ComputeAspectFromPoints(CGPoint topLeft, CGPoint bottomRight, CGPoint topRight, CGPoint bottomLeft, CGFloat imageWidth, CGFloat imageHeight);

CGFloat RadiansToDegrees(CGFloat radians);
CGFloat DegreesToRadians(CGFloat degrees);
CGPoint PointOnCircleAtAngle(CGFloat circleRadius, CGPoint circleCenter, CGFloat angleInDegrees);

CGFloat RemapValue(CGFloat value, CGFloat low1, CGFloat high1, CGFloat low2, CGFloat high2 );

CGFloat LoopFloat(CGFloat value, CGFloat min, CGFloat max);