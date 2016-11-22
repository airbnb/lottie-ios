//
//  ViewController.m
//  LotteExamples
//
//  Created by Brandon Withrow on 7/28/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "BBLotteExampleViewController.h"
#import "LAJSONExplorerViewController.h"

#import <Lotte/Lotte.h>

@interface BBLotteExampleViewController () <UITextFieldDelegate>

@end

@implementation BBLotteExampleViewController {
  UIButton *playButton;
  UIButton *loopButton;
  UISlider *animationSlider;
  UIButton *openButton;
  LAAnimationView *currentAnimation;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  CGFloat xOrigin = 0;
  NSArray *strings = @[@"begin", @"offset", @"duration", @"speed"];
  CGFloat xDiv = self.view.bounds.size.width / strings.count;
  
  
  for (int i = 0; i < strings.count; i ++) {
    CGRect textFieldFrame = CGRectMake(xOrigin, 20, xDiv, 60);
    UITextField *inputField = [[UITextField alloc] initWithFrame:textFieldFrame];
    inputField.tag = i;
    inputField.delegate = self;
    inputField.placeholder = strings[i];
    [self.view addSubview:inputField];
    
    textFieldFrame.origin.y += textFieldFrame.size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:strings[i] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
    button.frame = textFieldFrame;
    button.tag = i;
    [button addTarget:self action:@selector(setAnimationAttribute:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    xOrigin += xDiv;
  }
  
  
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
  LAJSONExplorerViewController *jsonView = [[LAJSONExplorerViewController alloc] init];
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
    [currentAnimation playWithCompletion:^{
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

- (void)setAnimationAttribute:(UIButton *)button {
//  NSArray *strings = @[@"begin", @"offset", @"duration", @"speed"];
  switch (button.tag) {
    case 0: {
      currentAnimation.debugBeginTime = CACurrentMediaTime();
    } break;
    case 1: {
      currentAnimation.debugTimeOffset = CACurrentMediaTime();
    } break;
    case 2: {
      
    } break;
    case 3: {
      
    } break;
    default:
      break;
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  switch (textField.tag) {
    case 0: {
      currentAnimation.debugBeginTime = textField.text.floatValue;
    } break;
    case 1: {
      currentAnimation.debugTimeOffset = textField.text.floatValue;

    } break;
    case 2: {
      currentAnimation.debugDuration = textField.text.floatValue;
    } break;
    case 3: {
      currentAnimation.debugSpeed = textField.text.floatValue;
    } break;
    default:
      break;
  }
}

// timeOffset
// beginTime
// duration
// speed

@end
