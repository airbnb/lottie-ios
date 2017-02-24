//
//  SplitDimensions.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface SplitDimensions : LottieAnimationTestCase

@end

@implementation SplitDimensions

- (void)setUp {
  self.animationName = @"SplitDimensions";
  [super setUp];
}

- (void)testSplitDimensions0 {
  [self testAnimationProgress:0];
}

- (void)testSplitDimensions50 {
  [self testAnimationProgress:0.5];
}

- (void)testSplitDimensions100 {
  [self testAnimationProgress:1];
}


@end
