//
//  TrimPathsFull.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface TrimPathsFull : LottieAnimationTestCase

@end

@implementation TrimPathsFull

- (void)setUp {
  self.animationName = @"TrimPathsFull";
  [super setUp];
}

- (void)testTrimPathsFull0 {
  [self testAnimationProgress:0];
}

- (void)testTrimPathsFull50 {
  [self testAnimationProgress:0.5];
}

- (void)testTrimPathsFull100 {
  [self testAnimationProgress:1];
}


@end
