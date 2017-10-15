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
  
  /// On animation is 0.5 to 1 progress.
  [toggle1 setProgressRangeForOnState:0.5 toProgress:1];
  /// Off animation is 0 to 0.5 progress.
  [toggle1 setProgressRangeForOffState:0 toProgress:0.5];
  
  [toggle1 addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:toggle1];
  
  /// An animated 'like' or 'heart' button.
  /// Clicking toggles the Like or Heart state.
  /// The animation runs from 0-1, progress 0 is off, progress 1 is on
  LOTAnimatedSwitch *heartIcon = [LOTAnimatedSwitch switchNamed:@"TwitterHeart"];
  
  [heartIcon addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:heartIcon];
  
  /// This is a switch that also has a Disabled state animation.
  /// When the switch is disabled then the disabled layer is displayed.
  
  LOTAnimatedSwitch *statefulSwitch = [LOTAnimatedSwitch switchNamed:@"Switch_States"];
  
  /// Off animation is 0 to 1 progress.
  /// On animation is 1 to 0 progress.
  [statefulSwitch setProgressRangeForOnState:1 toProgress:0];
  [statefulSwitch setProgressRangeForOffState:0 toProgress:1];
  
  // Specify the layer names for different states
  [statefulSwitch setLayerName:@"Button" forState:UIControlStateNormal];
  [statefulSwitch setLayerName:@"Disabled" forState:UIControlStateDisabled];
  
  // Changes visual appearance by switching animation layer to "Disabled"
  statefulSwitch.enabled = NO;
  
  // Changes visual appearance by switching animation layer to "Button"
  statefulSwitch.enabled = YES;
  
  [statefulSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:statefulSwitch];
  
  // Layout
  toggle1.center = CGPointMake(CGRectGetMidX(self.view.bounds), 90);
  heartIcon.bounds = CGRectMake(0, 0, 200, 200);
  heartIcon.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(toggle1.frame) + (heartIcon.bounds.size.height * 0.5));
  statefulSwitch.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(heartIcon.frame) + (statefulSwitch.bounds.size.height * 0.5));
}

- (void)switchToggled:(LOTAnimatedSwitch *)animatedSwitch {
  NSLog(@"The switch is %@", (animatedSwitch.on ? @"ON" : @"OFF"));
}

- (void)close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
