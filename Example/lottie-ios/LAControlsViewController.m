//
//  LAControlsViewController.m
//  lottie-ios
//
//  Created by brandon_withrow on 8/28/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LAControlsViewController.h"
#import <Lottie/Lottie.h>

@interface LAControlsViewController ()

@end

@implementation LAControlsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIButton *closeButton_ = [UIButton buttonWithType:UIButtonTypeSystem];
  [closeButton_ setTitle:@"Close" forState:UIControlStateNormal];
  [closeButton_ addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeButton_];
  CGSize buttonSize = [closeButton_ sizeThatFits:self.view.bounds.size];
  closeButton_.frame = CGRectMake(10, 30, buttonSize.width, 50);
  
  /// An animated toggle with different ON and OFF animations.
  
  LOTAnimatedSwitch *toggle1 = [LOTAnimatedSwitch switchNamed:@"Switch"];
  
  /// Off animation is 0 to 0.5 progress.
  /// On animation is 0.5 to 1 progress.
  [toggle1 setProgressRangeForOnState:0.5 toProgress:1];
  [toggle1 setProgressRangeForOffState:0 toProgress:0.5];
  
  [toggle1 addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
  toggle1.center = CGPointMake(CGRectGetMidX(self.view.bounds), 90);
  [self.view addSubview:toggle1];
  
  /// An animated 'like' or 'heart' button.
  /// Clicking toggles the Like or Heart state.
  /// The animation runs from 0-1, progress 0 is off, progress 1 is on
  LOTAnimatedSwitch *heartIcon = [LOTAnimatedSwitch switchNamed:@"TwitterHeart"];
  heartIcon.bounds = CGRectMake(0, 0, 200, 200);
  heartIcon.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(toggle1.frame) + (heartIcon.bounds.size.height * 0.5));
  [heartIcon addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:heartIcon];
  
}

- (void)switchToggled:(LOTAnimatedSwitch *)animatedSwitch {
  NSLog(@"The switch is %@", (animatedSwitch.on ? @"ON" : @"OFF"));
}

- (void)close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
