//
//  EmpyStateTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface EmpyStateTest : LottieAnimationTestCase

@end

@implementation EmpyStateTest

- (void)setUp {
  self.animationName = @"EmptyState";
  [super setUp];
}

- (void)testEmpyStateTest0 {
  [self testAnimationProgress:0];
}

- (void)testEmpyStateTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testEmpyStateTest100 {
  [self testAnimationProgress:1];
}


@end
