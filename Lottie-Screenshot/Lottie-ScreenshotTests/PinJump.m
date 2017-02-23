//
//  PinJump.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface PinJump : LottieAnimationTestCase

@end

@implementation PinJump

- (void)setUp {
  self.animationName = @"PinJump";
  [super setUp];
}

- (void)testPinJump0 {
  [self testAnimationProgress:0];
}

- (void)testPinJump50 {
  [self testAnimationProgress:0.5];
}

- (void)testPinJump100 {
  [self testAnimationProgress:1];
}


@end
