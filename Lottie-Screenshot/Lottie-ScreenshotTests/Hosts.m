//
//  Hosts.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface Hosts : LottieAnimationTestCase

@end

@implementation Hosts

- (void)setUp {
  self.animationName = @"Hosts";
  [super setUp];
}

- (void)testHosts0 {
  [self testAnimationProgress:0];
}

- (void)testHosts15 {
  [self testAnimationProgress:0.15];
}

- (void)testHosts25 {
  [self testAnimationProgress:0.25];
}

- (void)testHosts50 {
  [self testAnimationProgress:0.5];
}

- (void)testHosts100 {
  [self testAnimationProgress:1];
}


@end
