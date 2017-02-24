//
//  CityTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"


@interface CityTest : LottieAnimationTestCase

@end

@implementation CityTest

- (void)setUp {
  self.animationName = @"City";
  [super setUp];
}

- (void)testCity0 {
  [self testAnimationProgress:0];
}

- (void)testCity15 {
  [self testAnimationProgress:0.15];
}

- (void)testCity25 {
  [self testAnimationProgress:0.25];
}

- (void)testCity50 {
  [self testAnimationProgress:0.5];
}

- (void)testCity100 {
  [self testAnimationProgress:1];
}

@end
