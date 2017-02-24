//
//  LottieLogoTestB.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface LottieLogoTestB : LottieAnimationTestCase
@end

@implementation LottieLogoTestB

- (void)setUp {
  self.animationName = @"LottieLogo2";
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
