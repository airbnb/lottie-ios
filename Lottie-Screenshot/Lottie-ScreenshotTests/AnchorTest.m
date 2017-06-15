//
//  AnchorTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/27/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface AnchorTest : LottieAnimationTestCase

@end

@implementation AnchorTest

- (void)setUp {
  self.animationName = @"anchorTest";
  [super setUp];
}

- (void)testAnchorTest0 {
  [self testAnimationProgress:0];
}

- (void)testAnchorTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testAnchorTest100 {
  [self testAnimationProgress:1];
}


@end
