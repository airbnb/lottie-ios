//
//  AnimationTransitionViewController.m
//  LottieExamples
//
//  Created by brandon_withrow on 1/25/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "AnimationTransitionViewController.h"
#import <Lottie/Lottie.h>

@interface ToAnimationViewController : UIViewController
@property (nonnull, strong) UIButton *button1;
@end

@implementation ToAnimationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.button1 setTitle:@"Show Transition B" forState:UIControlStateNormal];
  [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.button1.backgroundColor = [UIColor colorWithRed:16.f/255.f
                                                 green:122.f/255.f
                                                  blue:134.f/255.f
                                                 alpha:1.f];
  self.button1.layer.cornerRadius = 7;
  
  [self.button1 addTarget:self action:@selector(_close) forControlEvents:UIControlEventTouchUpInside];
  self.view.backgroundColor = [UIColor colorWithRed:200.f/255.f
                                              green:66.f/255.f
                                               blue:72.f/255.f
                                              alpha:1.f];
  [self.view addSubview:self.button1];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  CGRect b = self.view.bounds;
  CGSize buttonSize = [self.button1 sizeThatFits:b.size];
  buttonSize.width += 20;
  buttonSize.height += 20;
  CGRect buttonRect;
  buttonRect.origin.x = b.origin.x + rintf(0.5f * (b.size.width - buttonSize.width));
  buttonRect.origin.y = b.origin.y + rintf(0.5f * (b.size.height - buttonSize.height));
  buttonRect.size = buttonSize;
  
  self.button1.frame = buttonRect;
}

- (void)_close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end

@interface AnimationTransitionViewController () <UIViewControllerTransitioningDelegate>

@property (nonnull, strong) UIButton *button1;
@property (nonnull, strong) UIButton *closeButton;

@end

@implementation AnimationTransitionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.closeButton setTitle:@"Close" forState:UIControlStateNormal];
  [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.closeButton.backgroundColor = [UIColor colorWithRed:50.f/255.f
                                                     green:207.f/255.f
                                                      blue:193.f/255.f
                                                     alpha:1.f];
  self.closeButton.layer.cornerRadius = 7;
  
  [self.closeButton addTarget:self action:@selector(_close) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.closeButton];
  
  
  self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.button1 setTitle:@"Show Transition A" forState:UIControlStateNormal];
  [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.button1.backgroundColor = [UIColor colorWithRed:50.f/255.f
                                                 green:207.f/255.f
                                                  blue:193.f/255.f
                                                 alpha:1.f];
  self.button1.layer.cornerRadius = 7;
  
  [self.button1 addTarget:self action:@selector(_showTransitionA) forControlEvents:UIControlEventTouchUpInside];
  self.view.backgroundColor = [UIColor colorWithRed:122.f/255.f
                                              green:8.f/255.f
                                               blue:81.f/255.f
                                              alpha:1.f];
  [self.view addSubview:self.button1];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  CGRect b = self.view.bounds;
  CGSize buttonSize = [self.button1 sizeThatFits:b.size];
  buttonSize.width += 20;
  buttonSize.height += 20;
  self.button1.bounds = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
  self.button1.center = self.view.center;
  
  
  CGSize closeSize = [self.closeButton sizeThatFits:b.size];
  closeSize.width += 20;
  closeSize.height += 20;
  
  self.closeButton.bounds = CGRectMake(0, 0, closeSize.width, closeSize.height);
  self.closeButton.center = CGPointMake(self.button1.center.x, CGRectGetMaxY(b) - closeSize.height);
}

- (void)_showTransitionA {
  ToAnimationViewController *vc = [[ToAnimationViewController alloc] init];
  vc.transitioningDelegate = self;
  [self presentViewController:vc animated:YES completion:NULL];
}

- (void)_close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -- View Controller Transitioning

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  LOTAnimationTransitionController *animationController = [[LOTAnimationTransitionController alloc] initWithAnimationNamed:@"vcTransition1"
                                                                                                            fromLayerNamed:@"outLayer"
                                                                                                              toLayerNamed:@"inLayer"
                                                                                                   applyAnimationTransform:NO];
  return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  LOTAnimationTransitionController *animationController = [[LOTAnimationTransitionController alloc] initWithAnimationNamed:@"vcTransition2"
                                                                                                            fromLayerNamed:@"outLayer"
                                                                                                              toLayerNamed:@"inLayer"
                                                                                                   applyAnimationTransform:NO];
  return animationController;
}


@end
