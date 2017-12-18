//
//  LAGeometryTest.m
//  lottie-ios_Tests
//
//  Created by brandon_withrow on 12/18/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>

@interface LAGeometryTest : XCTestCase

@property (nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation LAGeometryTest

- (void)setUp {
    [super setUp];
    self.animationView = [LOTAnimationView animationNamed:@"GeometryTransformTest"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAnimationLoaded {
  XCTAssertNotNil(self.animationView.sceneModel, @"Animation Composition is nil");
}

- (void)testGeometryCenter {
  LOTKeypath *keypath = [LOTKeypath keypathWithKeys:@"Center", @"Ellipse 1", nil];
  CGPoint midPoint = CGPointMake(CGRectGetMidX(self.animationView.bounds), CGRectGetMidY(self.animationView.bounds));
  CGPoint midPointInChildSpace = [self.animationView convertPoint:midPoint toKeypathLayer:keypath];
  CGPoint midPointInParentSpace = [self.animationView convertPoint:CGPointZero fromKeypathLayer:keypath];
  XCTAssertTrue((CGPointEqualToPoint(midPointInChildSpace, CGPointZero)), @"Convert to point incorrect");
  XCTAssertTrue((CGPointEqualToPoint(midPointInParentSpace, midPoint)), @"Convert from point incorrect");
}

- (void)testGeometryBottomRight {
  LOTKeypath *keypath = [LOTKeypath keypathWithKeys:@"BottomRight", @"Ellipse 1", nil];
  CGPoint midPoint = CGPointMake(CGRectGetMidX(self.animationView.bounds), CGRectGetMidY(self.animationView.bounds));
  CGPoint bottomRightPoint = CGPointMake(CGRectGetMaxX(self.animationView.bounds), CGRectGetMaxY(self.animationView.bounds));
  CGPoint midPointInChildSpace = [self.animationView convertPoint:midPoint toKeypathLayer:keypath];
  CGPoint midPointInParentSpace = [self.animationView convertPoint:CGPointZero fromKeypathLayer:keypath];
  XCTAssertTrue((CGPointEqualToPoint(midPointInChildSpace, CGPointMake(-midPoint.x, -midPoint.y))), @"Convert to point incorrect");
  XCTAssertTrue((CGPointEqualToPoint(midPointInParentSpace, bottomRightPoint)), @"Convert from point incorrect");
}

- (void)testGeometryScaled {
  LOTKeypath *keypath = [LOTKeypath keypathWithKeys:@"Scaled", @"Ellipse 1", nil];
  CGPoint bottomRightPoint = CGPointMake(CGRectGetMaxX(self.animationView.bounds), CGRectGetMaxY(self.animationView.bounds));
  CGPoint topLeftInChildSpace = [self.animationView convertPoint:CGPointZero toKeypathLayer:keypath];
  CGPoint bottomRightInParentSpace = [self.animationView convertPoint:CGPointMake(75, 75) fromKeypathLayer:keypath];
  XCTAssertTrue((CGPointEqualToPoint(bottomRightInParentSpace, bottomRightPoint)), @"Convert to point incorrect");
  XCTAssertTrue((CGPointEqualToPoint(topLeftInChildSpace, CGPointMake(-75, -75))), @"Convert from point incorrect");
}

@end
