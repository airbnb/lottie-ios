//
//  PathStrokeTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface PathStrokeTest : LottieAnimationTestCase

@end

@implementation PathStrokeTest

- (void)setUp {
  self.animationName = @"pathStrokeTests";
  [super setUp];
}

- (void)testPathStroke0 {
  [self testAnimationProgress:0];
}

- (void)testPathStroke50 {
  [self testAnimationProgress:0.5];
}

- (void)testPathStroke100 {
  [self testAnimationProgress:1];
}

@end
