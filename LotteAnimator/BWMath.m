//
//  BWMath.m
//  Perfective
//
//  Created by Brandon Withrow on 5/11/14.
//  Copyright (c) 2014 Brandon Withrow. All rights reserved.
//
#import "BWMath.h"

GLKMatrix3 General2dProjection(CGFloat x1s, CGFloat y1s, CGFloat x1d, CGFloat y1d,
                               CGFloat x2s, CGFloat y2s, CGFloat x2d, CGFloat y2d,
                               CGFloat x3s, CGFloat y3s, CGFloat x3d, CGFloat y3d,
                               CGFloat x4s, CGFloat y4s, CGFloat x4d, CGFloat y4d) {
  GLKMatrix3 s = BasisToPoints(x1s, y1s, x2s, y2s, x3s, y3s, x4s, y4s);
  GLKMatrix3 d = BasisToPoints(x1d, y1d, x2d, y2d, x3d, y3d, x4d, y4d);
  GLKMatrix3 sa = AdjugateOfMatrix(s);
  return PositiveMultiplyMatrix(d, sa);
}

GLKMatrix3 AdjugateOfMatrix(GLKMatrix3 m) { // Compute the adjugate of m
  
  GLKMatrix3 r;
  r.m[0] = m.m[4]*m.m[8]-m.m[5]*m.m[7];
  r.m[1] = m.m[2]*m.m[7]-m.m[1]*m.m[8];
  r.m[2] = m.m[1]*m.m[5]-m.m[2]*m.m[4];
  r.m[3] = m.m[5]*m.m[6]-m.m[3]*m.m[8];
  r.m[4] = m.m[0]*m.m[8]-m.m[2]*m.m[6];
  r.m[5] = m.m[2]*m.m[3]-m.m[0]*m.m[5];
  r.m[6] = m.m[3]*m.m[7]-m.m[4]*m.m[6];
  r.m[7] = m.m[1]*m.m[6]-m.m[0]*m.m[7];
  r.m[8] = m.m[0]*m.m[4]-m.m[1]*m.m[3];
  return r;
}

GLKVector3 multmv(GLKMatrix3 m, GLKVector3 v) { // multiply matrix and vector
  GLKVector3 r;
  r.v[0] = m.m[0]*v.v[0] + m.m[1]*v.v[1] + m.m[2]*v.v[2];
  r.v[1] = m.m[3]*v.v[0] + m.m[4]*v.v[1] + m.m[5]*v.v[2];
  r.v[2] = m.m[6]*v.v[0] + m.m[7]*v.v[1] + m.m[8]*v.v[2];
  return r;
}

GLKVector3 multmvt(GLKMatrix3 m, GLKVector3 v) { // multiply matrix and transposed vector
  GLKVector3 r;
  r.v[0] = m.m[0]*v.v[0] + m.m[1]*v.v[0] + m.m[2]*v.v[0];
  r.v[1] = m.m[3]*v.v[1] + m.m[4]*v.v[1] + m.m[5]*v.v[1];
  r.v[2] = m.m[6]*v.v[2] + m.m[7]*v.v[2] + m.m[8]*v.v[2];
  return r;
}

GLKMatrix3 BasisToPoints(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat x3, CGFloat y3, CGFloat x4, CGFloat y4) {
  GLKMatrix3 m;
  m = GLKMatrix3Make(x1, x2, x3, y1, y2, y3, 1,  1,  1);
  GLKMatrix3 ma = AdjugateOfMatrix(m);
  GLKVector3 v = multmv(ma, GLKVector3Make(x4, y4, 1));
  GLKMatrix3 mb = GLKMatrix3Make(v.v[0], 0, 0, 0, v.v[1], 0, 0, 0, v.v[2]);
  return PositiveMultiplyMatrix(m, mb);
}

GLKMatrix3 PositiveMultiplyMatrix(GLKMatrix3 a, GLKMatrix3 b) { // multiply two matrices
  GLKMatrix3 c;
  for (int i = 0; i != 3; ++i) {
    for (int j = 0; j != 3; ++j) {
      float cij = 0;
      for (int k = 0; k != 3; ++k) {
        cij += a.m[3*i + k]*b.m[3*k + j];
      }
      c.m[3*i + j] = cij;
    }
  }
  return c;
}

GLKMatrix4 HomographicMatrix(CGFloat width, CGFloat height, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight) {
  GLKMatrix3 t = General2dProjection(0, 0, topLeft.x, topLeft.y,
                                     width, 0, topRight.x, topRight.y,
                                     0, height, bottomLeft.x, bottomLeft.y,
                                     width, height, bottomRight.x, bottomRight.y);
  for(int i = 0; i != 9; ++i) {
    t.m[i] = t.m[i]/t.m[8];
  }
  GLKMatrix4 r = GLKMatrix4Make(t.m[0], t.m[3], 0, t.m[6],
                                t.m[1], t.m[4], 0, t.m[7],
                                0, 0, 1, 0,
                                t.m[2], t.m[5], 0, t.m[8]);
  return r;
}

GLKMatrix4 TransHomographicMatrix(CGFloat width, CGFloat height, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight) {
  GLKMatrix4 r = HomographicMatrix(width, height, topLeft, topRight, bottomLeft, bottomRight);
  bool is;
  GLKMatrix4 invertR = GLKMatrix4Invert(r, &is);
  return invertR;
}

CGFloat DistanceBetweenTwoPoints(CGPoint point1,CGPoint point2) {
  CGFloat dx = point2.x - point1.x;
  CGFloat dy = point2.y - point1.y;
  return sqrt(dx*dx + dy*dy );
};

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

GLKVector4 QuadrilateralQForPoints(CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight) {
  CGPoint p0, p1,p2, p3;
  p0 = bottomLeft; // bottom left
  p1 = bottomRight; // bottom right
  p2 = topRight; // top right
  p3 = topLeft; // top left
  CGPoint center = IntersectionOfPoints(topLeft, bottomRight, topRight, bottomLeft);
  
  CGFloat d0, d1, d2, d3;
  d0 = DistanceBetweenTwoPoints(p0, center);
  d1 = DistanceBetweenTwoPoints(p1, center);
  d2 = DistanceBetweenTwoPoints(p2, center);
  d3 = DistanceBetweenTwoPoints(p3, center);
  
  CGFloat w0, w1, w2, w3;
  w0 = (d0 + d2) / d2;
  w1 = (d1 + d3) / d3;
  w2 = (d2 + d0) / d0;
  w3 = (d3 + d1) / d1;
  return GLKVector4Make(w3, w2, w0, w1);
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

CGFloat ComputeAspectFromPoints(CGPoint topLeft, CGPoint bottomRight, CGPoint topRight, CGPoint bottomLeft, CGFloat imageWidth, CGFloat imageHeight) {
  CGFloat u, v;
  u = imageWidth * 0.5;
  v = imageHeight * 0.5;
  GLKVector3 m3 = GLKVector3Make(bottomLeft.x, bottomLeft.y, 1);
  GLKVector3 m4 = GLKVector3Make(bottomRight.x, bottomRight.y, 1);
  GLKVector3 m1 = GLKVector3Make(topLeft.x, topLeft.y, 1);
  GLKVector3 m2 = GLKVector3Make(topRight.x, topRight.y, 1);

  CGFloat m1x = m1.x - u;
  CGFloat m1y = m1.y - v;
  CGFloat m2x = m2.x - u;
  CGFloat m2y = m2.y - v;
  CGFloat m3x = m3.x - u;
  CGFloat m3y = m3.y - v;
  CGFloat m4x = m4.x - u;
  CGFloat m4y = m4.y - v;

  CGFloat k2 = ((m1y - m4y)*m3x - (m1x - m4x)*m3y + m1x*m4y - m1y*m4x) /
  ((m2y - m4y)*m3x - (m2x - m4x)*m3y + m2x*m4y - m2y*m4x) ;
  
  CGFloat k3 = ((m1y - m4y)*m2x - (m1x - m4x)*m2y + m1x*m4y - m1y*m4x) /
  ((m3y - m4y)*m2x - (m3x - m4x)*m2y + m3x*m4y - m3y*m4x) ;
  
  CGFloat f_squared = -((k3*m3y - m1y)*(k2*m2y - m1y) + (k3*m3x - m1x)*(k2*m2x - m1x)) / ((k3 - 1)*(k2 - 1));

  CGFloat whRatio = sqrt((sqr(k2 - 1) + sqr(k2*m2y - m1y)/f_squared + sqr(k2*m2x - m1x)/f_squared) /
                         (sqr(k3 - 1) + sqr(k3*m3y - m1y)/f_squared + sqr(k3*m3x - m1x)/f_squared));

  if ((k2==1 && k3==1) || whRatio == 0) {
    whRatio = sqrt((sqr(m2y-m1y) + sqr(m2x-m1x)) /
                   (sqr(m3y-m1y) + sqr(m3x-m1x)));
  }

  return whRatio;
}

GLKMatrix4 GLKMatrix4Slerp(GLKMatrix4 from, GLKMatrix4 to, CGFloat amount) {
  GLKQuaternion q1 = GLKQuaternionMakeWithMatrix4(from);
  GLKQuaternion q2 = GLKQuaternionMakeWithMatrix4(to);
  GLKQuaternion r1 = GLKQuaternionSlerp(q1, q2, amount);
  GLKVector4 t1 = GLKVector4Make(from.m30, from.m31, from.m32, from.m33);
  GLKVector4 t2 = GLKVector4Make(to.m30, to.m31, to.m32, to.m33);
  GLKVector4 r2 = GLKVector4Lerp(t1, t2, amount);
  
  GLKMatrix4 rX = GLKMatrix4MakeWithQuaternion(r1);
  rX.m30 = r2.x;
  rX.m31 = r2.y;
  rX.m32 = r2.z;
  return rX;
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
