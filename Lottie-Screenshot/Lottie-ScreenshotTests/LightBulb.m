//
//  LightBulb.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface LightBulb : LottieAnimationTestCase

@end

@implementation LightBulb

- (void)setUp {
  self.animationName = @"LightBulb";
  [super setUp];
}

- (void)testLightBulb0 {
  [self testAnimationProgress:0];
}

- (void)testLightBulb50 {
  [self testAnimationProgress:0.5];
}

- (void)testLightBulb100 {
  [self testAnimationProgress:1];
}


@end
