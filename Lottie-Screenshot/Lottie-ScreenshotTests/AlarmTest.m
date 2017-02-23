//
//  AlarmTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface AlarmTest : LottieAnimationTestCase

@end

@implementation AlarmTest

- (void)setUp {
  self.animationName = @"Alarm";
  [super setUp];
}

- (void)testAlarm0 {
  [self testAnimationProgress:0];
}

- (void)testAlarm50 {
  [self testAnimationProgress:0.5];
}

- (void)testAlarm100 {
  [self testAnimationProgress:1];
}

@end
