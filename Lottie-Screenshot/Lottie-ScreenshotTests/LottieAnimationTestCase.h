//
//  LottieAnimationTestCase.h
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import <Lottie/Lottie.h>

@interface LottieAnimationTestCase : FBSnapshotTestCase

@property (nonatomic, strong) NSString *animationName;

- (void)testAnimationProgress:(float)progress;

@end
