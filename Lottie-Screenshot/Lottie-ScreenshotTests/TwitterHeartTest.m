//
//  TwitterHeartTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface TwitterHeartTest : LottieAnimationTestCase

@end

@implementation TwitterHeartTest

- (void)setUp {
  self.animationName = @"TwitterHeart";
  [super setUp];
}

- (void)testTwitterHeartTest0 {
  [self testAnimationProgress:0];
}

- (void)testTwitterHeartTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testTwitterHeartTest100 {
  [self testAnimationProgress:1];
}


@end
