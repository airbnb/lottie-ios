//
//  AnimationBundleViewController.m
//  lottie-ios
//
//  Created by gejw on 2017/6/26.
//  Copyright © 2017年 Brandon Withrow. All rights reserved.
//

#import "AnimationBundleViewController.h"
#import <Lottie/Lottie.h>

@interface AnimationBundleViewController()

@property (nonnull, strong) UIButton *closeButton;

@property (nonatomic, strong) LOTAnimationView *lottieLogo;

@end

@implementation AnimationBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"itemfinder" ofType:@"bundle"]];
    self.lottieLogo = [LOTAnimationView animationNamed:@"data" inBundle:bundle];
    self.lottieLogo.contentMode = UIViewContentModeScaleAspectFill;
    self.lottieLogo.frame = self.view.bounds;
    [self.view addSubview:self.lottieLogo];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height - 50, 80, 40);
    [self.closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeButton.backgroundColor = [UIColor colorWithRed:50.f/255.f
                                                       green:207.f/255.f
                                                        blue:193.f/255.f
                                                       alpha:1.f];
    self.closeButton.layer.cornerRadius = 7;

    [self.closeButton addTarget:self action:@selector(_close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
}

- (void)_close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.lottieLogo play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.lottieLogo pause];
}

@end
