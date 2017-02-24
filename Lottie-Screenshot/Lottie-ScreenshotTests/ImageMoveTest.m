//
//  ImageMoveTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/24/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface ImageMoveTest : LottieAnimationTestCase

@end

@implementation ImageMoveTest

- (void)setUp {
  self.animationName = @"image_2";
  [super setUp];
}

- (void)testImageMoveTest0 {
  [self testAnimationProgress:0];
}

- (void)testImageMoveTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testImageMoveTest100 {
  [self testAnimationProgress:1];
}


@end
