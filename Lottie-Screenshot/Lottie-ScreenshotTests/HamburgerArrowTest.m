//
//  HamburgerArrowTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface HamburgerArrowTest : LottieAnimationTestCase

@end

@implementation HamburgerArrowTest

- (void)setUp {
  self.animationName = @"HamburgerArrow";
  [super setUp];
}

- (void)testHamburgerArrowTest0 {
  [self testAnimationProgress:0];
}

- (void)testHamburgerArrowTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testHamburgerArrowTest100 {
  [self testAnimationProgress:1];
}


@end
