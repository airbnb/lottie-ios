//
//  CheckSwitchTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface CheckSwitchTest : LottieAnimationTestCase

@end

@implementation CheckSwitchTest

- (void)setUp {
  self.animationName = @"CheckSwitch";
  [super setUp];
}

- (void)testCheckSwitch0 {
  [self testAnimationProgress:0];
}

- (void)testCheckSwitch50 {
  [self testAnimationProgress:0.5];
}

- (void)testCheckSwitch100 {
  [self testAnimationProgress:1];
}

@end
