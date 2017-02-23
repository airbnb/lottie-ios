//
//  AlBoardmanTest.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>
#import "LottieAnimationTestCase.h"

@interface AlBoardmanTest : LottieAnimationTestCase

@end

@implementation AlBoardmanTest

- (void)setUp {
  self.animationName = @"9squares-AlBoardman";
  [super setUp];
}

- (void)testAlBoardmanTest0 {
  [self testAnimationProgress:0];
}

- (void)testAlBoardmanTest50 {
  [self testAnimationProgress:0.5];
}

- (void)testAlBoardmanTest100 {
  [self testAnimationProgress:1];
}


@end
