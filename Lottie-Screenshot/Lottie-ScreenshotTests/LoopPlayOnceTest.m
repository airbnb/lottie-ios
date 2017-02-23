//
//  LoopPlayOnceTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface LoopPlayOnceTest : LottieAnimationTestCase

@end

@implementation LoopPlayOnceTest

- (void)setUp {
  self.animationName = @"LoopPlayOnce";
  [super setUp];
}

- (void)testLoopPlayOnceTest0 {
  [self testAnimationProgress:0];
}

- (void)testLoopPlayOnceTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testLoopPlayOnceTest100 {
  [self testAnimationProgress:1];
}


@end
