//
//  ViewController.m
//  LottieExamples
//
//  Created by Brandon Withrow on 7/28/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LottieExampleViewController.h"
#import "JSONExplorerViewController.h"

#import <Lottie/Lottie.h>

@interface LottieExampleViewController () <UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@end

@implementation LottieExampleViewController {
  UIButton *playButton;
  UIButton *loopButton;
  UISlider *animationSlider;
  UIButton *openButton;
  LAAnimationView *currentAnimation;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  openButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [openButton setTitle:@"Open" forState:UIControlStateNormal];
  [self.view addSubview:openButton];
  
  playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [playButton setTitle:@"Play" forState:UIControlStateNormal];
  [self.view addSubview:playButton];
  
  loopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [loopButton setTitle:@"Loop" forState:UIControlStateNormal];
  [self.view addSubview:loopButton];
  
  animationSlider = [[UISlider alloc] initWithFrame:CGRectZero];
  [self.view addSubview:animationSlider];
  
  [openButton addTarget:self action:@selector(_openPressed) forControlEvents:UIControlEventTouchUpInside];
  [playButton addTarget:self action:@selector(_playPressed) forControlEvents:UIControlEventTouchUpInside];
  [loopButton addTarget:self action:@selector(_loopPressed) forControlEvents:UIControlEventTouchUpInside];
  [animationSlider addTarget:self action:@selector(_sliderChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGSize boundsSize = self.view.bounds.size;
  CGSize buttonSize = [openButton sizeThatFits:boundsSize];
  openButton.frame = CGRectMake(10, boundsSize.height - 60, buttonSize.width + 20, 44);
  
  buttonSize = [playButton sizeThatFits:boundsSize];
  playButton.frame = CGRectMake(CGRectGetMaxX(openButton.frame) + 10, CGRectGetMinY(openButton.frame), buttonSize.width + 20, 44);
  
  buttonSize = [loopButton sizeThatFits:boundsSize];
  loopButton.frame = CGRectMake(CGRectGetMaxX(playButton.frame) + 10, CGRectGetMinY(playButton.frame), buttonSize.width + 20, 44);
  
  CGRect sliderRect = CGRectMake(CGRectGetMaxX(loopButton.frame) + 10, CGRectGetMinY(loopButton.frame), boundsSize.width - CGRectGetMaxX(loopButton.frame) - 20, 44);
  animationSlider.frame = sliderRect;
  
  currentAnimation.frame = CGRectMake(0, 180, boundsSize.width, boundsSize.height - 250);
}

- (void)_openPressed {
  JSONExplorerViewController *jsonView = [[JSONExplorerViewController alloc] init];
  jsonView.transitioningDelegate = self;
  [jsonView setCompletionBlock:^(NSString *path) {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self _openFileAtPath:path];
  }];
  [self presentViewController:jsonView animated:YES completion:nil];
}

- (void)_playPressed {
  if (currentAnimation.isAnimationPlaying) {
    [currentAnimation pause];
  } else {
    [currentAnimation playWithCompletion:^(BOOL animationFinished) {
      [self _updatePlayButtonTitle];
    }];
  }
  [self _updatePlayButtonTitle];
}

- (void)_updatePlayButtonTitle {
  NSString *title = currentAnimation.isAnimationPlaying ? @"Stop" : @"Play";
  [playButton setTitle:title forState:UIControlStateNormal];
}

- (void)_loopPressed {
  currentAnimation.loopAnimation = !currentAnimation.loopAnimation;
  [self _updatePlayButtonTitle];
}

- (void)_sliderChanged {
  currentAnimation.animationProgress = animationSlider.value;
  [self _updatePlayButtonTitle];
}

- (void)_openFileAtURL:(NSURL *)url {
  currentAnimation = [[LAAnimationView alloc] initWithContentsOfURL:url];
  currentAnimation.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:currentAnimation];
  [currentAnimation play];
  [self _updatePlayButtonTitle];
  [self.view setNeedsLayout];
}

- (void)_openFileAtPath:(NSString *)filePath {
  NSError *error;
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0 error:&error];
  
  if (!error) {
    [currentAnimation removeFromSuperview];
    currentAnimation = [LAAnimationView animationFromJSON:JSONObject];
    currentAnimation.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:currentAnimation];

    [self _updatePlayButtonTitle];
    [self.view setNeedsLayout];
  }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  LAAnimationTransistionController *animationController = [[LAAnimationTransistionController alloc] initWithAnimationNamed:@"vcTransition1"
                                                                                                            fromLayerNamed:@"outLayer"
                                                                                                              toLayerNamed:@"inLayer"];
  return animationController;
}

@end
