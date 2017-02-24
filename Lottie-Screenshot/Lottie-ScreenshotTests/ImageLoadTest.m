//
//  ImageLoadTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/24/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface ImageLoadTest : LottieAnimationTestCase

@end

@implementation ImageLoadTest

- (void)setUp {
  self.animationName = @"Image";
  [super setUp];
}

- (void)testImageLoadTest0 {
  [self testAnimationProgress:0];
}

- (void)testImageLoadTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testImageLoadTest100 {
  [self testAnimationProgress:1];
}


@end
