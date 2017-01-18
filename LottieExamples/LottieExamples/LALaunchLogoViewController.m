//
//  LALaunchLogoViewController.m
//  LottieExamples
//
//  Created by Brandon Withrow on 1/17/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LALaunchLogoViewController.h"
#import <Lottie/Lottie.h>

@interface LALaunchLogoViewController ()

@property (nonatomic, strong) LAAnimationView *logoView;

@end

@implementation LALaunchLogoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.logoView = [LAAnimationView animationNamed:@"LottieLogo1_masked"];
  self.logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.logoView.frame = self.view.bounds;
  self.logoView.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:self.logoView];
  // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.logoView playWithCompletion:^(BOOL animationFinished) {
    
  }];
}

@end
