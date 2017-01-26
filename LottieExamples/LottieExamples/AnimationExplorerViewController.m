//
//  AnimationExplorerViewController.m
//  LottieExamples
//
//  Created by brandon_withrow on 1/25/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "AnimationExplorerViewController.h"
#import "JSONExplorerViewController.h"
#import <Lottie/Lottie.h>

@interface AnimationExplorerViewController ()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) LAAnimationView *laAnimation;

@end

@implementation AnimationExplorerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
  
  UIBarButtonItem *open = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(_open:)];
  UIBarButtonItem *flx1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(_rewind:)];
  UIBarButtonItem *flx2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(_play:)];
  UIBarButtonItem *flx3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *loop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_loop:)];
  UIBarButtonItem *flx4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(_close:)];
  self.toolbar.items = @[open, flx1, rewind, flx2, play, flx3, loop, flx4, close];
  [self.view addSubview:self.toolbar];
  [self resetAllButtons];
  
  self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
  [self.slider addTarget:self action:@selector(_sliderChanged:) forControlEvents:UIControlEventValueChanged];
  self.slider.minimumValue = 0;
  self.slider.maximumValue = 1;
  [self.view addSubview:self.slider];
}

- (void)resetAllButtons {
  self.slider.value = 0;
  for (UIBarButtonItem *button in self.toolbar.items) {
    [self resetButton:button highlighted:NO];
  }
}

- (void)resetButton:(UIBarButtonItem *)button highlighted:(BOOL)highlighted {
  button.tintColor = highlighted ? [UIColor redColor] : [UIColor colorWithRed:50.f/255.f
                                                                        green:207.f/255.f
                                                                         blue:193.f/255.f
                                                                        alpha:1.f];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  CGRect b = self.view.bounds;
  self.toolbar.frame = CGRectMake(0, b.size.height - 44, b.size.width, 44);
  CGSize sliderSize = [self.slider sizeThatFits:b.size];
  sliderSize.height += 12;
  self.slider.frame = CGRectMake(10, CGRectGetMinY(self.toolbar.frame) - sliderSize.height, b.size.width - 20, sliderSize.height);
  self.laAnimation.frame = CGRectMake(0, 0, b.size.width, CGRectGetMinY(self.slider.frame));
}

- (void)_sliderChanged:(UISlider *)slider {
  self.laAnimation.animationProgress = slider.value;
}

- (void)_open:(UIBarButtonItem *)button {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open Animation"
                                                                 message:NULL
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
  
  UIAlertAction *browseAction = [UIAlertAction actionWithTitle:@"Browse" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                         [self _showJSONExplorer];
                                                       }];
  
  [alert addAction:browseAction];
  
  UIAlertAction *fromURLAction = [UIAlertAction actionWithTitle:@"Load from URL" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                          [self _showURLInput];
                                                        }];
  
  [alert addAction:fromURLAction];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)_showURLInput {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load From URL"
                                                                 message:NULL
                                                          preferredStyle:UIAlertControllerStyleAlert];
  
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"Enter URL";
  }];
  
  UIAlertAction *load = [UIAlertAction actionWithTitle:@"Load" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                         [self _loadAnimationFromURLString:alert.textFields.firstObject.text];
                                                       }];
  
  [alert addAction:load];
  
  UIAlertAction *close = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:NULL];
                                                        }];
  
  [alert addAction:close];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)_showJSONExplorer {
  JSONExplorerViewController *vc = [[JSONExplorerViewController alloc] init];
  [vc setCompletionBlock:^(NSString *selectedAnimation) {
    if (selectedAnimation) {
      [self _loadAnimationNamed:selectedAnimation];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
  }];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:navController animated:YES completion:NULL];
}

- (void)_loadAnimationFromURLString:(NSString *)URL {
  [self.laAnimation removeFromSuperview];
  self.laAnimation = nil;
  [self resetAllButtons];
  
  self.laAnimation = [[LAAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
  self.laAnimation.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:self.laAnimation];
  [self.view setNeedsLayout];
}

- (void)_loadAnimationNamed:(NSString *)named {
  [self.laAnimation removeFromSuperview];
  self.laAnimation = nil;
  [self resetAllButtons];
  
  self.laAnimation = [LAAnimationView animationNamed:named];
  self.laAnimation.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:self.laAnimation];
  [self.view setNeedsLayout];
}

- (void)_rewind:(UIBarButtonItem *)button {
  self.laAnimation.animationProgress = 0;
}

- (void)_play:(UIBarButtonItem *)button {
  if (self.laAnimation.isAnimationPlaying) {
    [self resetButton:button highlighted:NO];
    [self.laAnimation pause];
  } else {
    [self resetButton:button highlighted:YES];
    [self.laAnimation playWithCompletion:^(BOOL animationFinished) {
      self.slider.value = self.laAnimation.animationProgress;
      [self resetButton:button highlighted:NO];
    }];
  }
}

- (void)_loop:(UIBarButtonItem *)button {
  self.laAnimation.loopAnimation = !self.laAnimation.loopAnimation;
  [self resetButton:button highlighted:self.laAnimation.loopAnimation];
}

- (void)_close:(UIBarButtonItem *)button {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


@end
