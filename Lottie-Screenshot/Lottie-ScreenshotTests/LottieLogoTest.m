//
//  Lottie_ScreenshotUITests.m
//  Lottie-ScreenshotUITests
//
//  Created by Brandon Withrow on 2/21/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LottieAnimationTestCase.h"
#import <Lottie/Lottie.h>

@interface LottieLogoTest : LottieAnimationTestCase

@end

@implementation LottieLogoTest

- (void)setUp {
  self.animationName = @"LottieLogo1";
  [super setUp];
}

- (void)testLottieLogo0 {
  [self testAnimationProgress:0];
}

- (void)testLottieLogo15 {
  [self testAnimationProgress:0.15];
}

- (void)testLottieLogo25 {
  [self testAnimationProgress:0.25];
}

- (void)testLottieLogo50 {
  [self testAnimationProgress:0.5];
}

- (void)testLottieLogo100 {
  [self testAnimationProgress:1];
}

@end
