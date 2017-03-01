//
//  ImageTransformTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/27/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface ImageTransformTest : LottieAnimationTestCase

@end

@implementation ImageTransformTest

- (void)setUp {
  self.animationName = @"ImageXforms";
  [super setUp];
}

- (void)testImageTransformTest0 {
  [self testAnimationProgress:0];
}

- (void)testImageTransformTest25 {
  [self testAnimationProgress:0.25];
}

- (void)testImageTransformTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testImageTransformTest75 {
  [self testAnimationProgress:0.75];
}

- (void)testImageTransformTest100 {
  [self testAnimationProgress:1];
}

@end
