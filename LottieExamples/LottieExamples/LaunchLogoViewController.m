//
//  LALaunchLogoViewController.m
//  LottieExamples
//
//  Created by Brandon Withrow on 1/17/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LottieExampleViewController.h"
#import "LaunchLogoViewController.h"
#import <Lottie/Lottie.h>

@interface LaunchLogoViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIViewController *appRootViewController;

@end

@implementation LaunchLogoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:50.f/255.f
                                              green:207.f/255.f
                                               blue:193.f/255.f
                                              alpha:1.f];
  
  UIViewController *rootVC = [[LottieExampleViewController alloc] initWithNibName:nil bundle:nil];
  self.appRootViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
  self.appRootViewController.transitioningDelegate = self;
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (self.appRootViewController.presentingViewController == nil) {
    [self presentViewController:self.appRootViewController animated:YES completion:nil];
  }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  LAAnimationTransistionController *animationController = [[LAAnimationTransistionController alloc] initWithAnimationNamed:@"LottieLogo1_masked"
                                                                                                            fromLayerNamed:nil
                                                                                                              toLayerNamed:@"DotLayerMask"];
  return animationController;
}

@end
