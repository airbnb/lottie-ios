//
//  PhonePreCompTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/24/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface PhonePreCompTest : LottieAnimationTestCase

@end

@implementation PhonePreCompTest

- (void)setUp {
  self.animationName = @"phonePreComp";
  [super setUp];
}

- (void)testPhonePreCompTest25 {
  [self testAnimationProgress:0.25];
}

- (void)testPhonePreCompTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testPhonePreCompTest100 {
  [self testAnimationProgress:1];
}


@end
