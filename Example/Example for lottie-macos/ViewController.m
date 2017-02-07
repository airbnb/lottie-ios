//
//  ViewController.m
//  Example for lottie-macos
//
//  Created by Oleksii Pavlovskyi on 2/2/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"
#import <Lottie/Lottie.h>

@interface ViewController ()

@property (nonatomic, strong) LOTAnimationView *lottieLogo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lottieLogo = [LOTAnimationView animationNamed:@"LottieLogo1"];
    self.lottieLogo.contentMode = LOTViewContentModeScaleAspectFill;
    self.lottieLogo.frame = self.view.bounds;
    self.lottieLogo.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.view addSubview:self.lottieLogo];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.lottieLogo play];
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    [self.lottieLogo pause];
}

@end
