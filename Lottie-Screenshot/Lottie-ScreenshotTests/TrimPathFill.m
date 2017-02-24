//
//  TrimPathFill.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface TrimPathFill : LottieAnimationTestCase

@end

@implementation TrimPathFill

- (void)setUp {
  self.animationName = @"TrimPathFill";
  [super setUp];
}

- (void)testTrimPathFill100 {
  [self testAnimationProgress:1];
}


@end
