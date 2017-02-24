//
//  LottieAnimationTestCase.m
//  Lottie-Screenshot
//
//  Created by Brandon Withrow on 2/22/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LottieAnimationTestCase.h"
@interface LottieAnimationTestCase ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) LOTAnimationView *animationView;


@end

@implementation LottieAnimationTestCase

- (void)setUp {
  [super setUp];
//  self.recordMode = YES;
  self.usesDrawViewHierarchyInRect = YES;
  self.animationView = [LOTAnimationView animationNamed:self.animationName];
  self.window = [[UIWindow alloc] initWithFrame:self.animationView.bounds];
  self.window.rootViewController = [[UIViewController alloc] init];
  [self.window.rootViewController.view addSubview:self.animationView];
  [self.window makeKeyAndVisible];
}

- (void)testAnimationProgress:(float)progress {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Image"];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [NSThread sleepForTimeInterval:0.1];
    [expectation fulfill];
  }];
  
  self.animationView.animationProgress = progress;
  [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
    FBSnapshotVerifyView(self.animationView.layer, nil);
  }];
}

//-(void)tearDown {
//  [super tearDown];
//  [self.animationView removeFromSuperview];
//  self.animationView = nil;
//  [self.window resignKeyWindow];
//}

@end
