//
//  AllSetTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface AllSetTest : LottieAnimationTestCase

@end

@implementation AllSetTest

- (void)setUp {
  self.animationName = @"AllSet";
  [super setUp];
}

- (void)testAllSet0 {
  [self testAnimationProgress:0];
}

- (void)testAllSet30 {
  [self testAnimationProgress:0.3];
}

- (void)testAllSet50 {
  [self testAnimationProgress:0.5];
}

- (void)testAllSet100 {
  [self testAnimationProgress:1];
}

@end
