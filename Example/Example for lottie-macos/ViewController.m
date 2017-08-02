//
//  ViewController.m
//  Example for lottie-macos
//
//  Created by Oleksii Pavlovskyi on 2/2/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"
#import <Lottie/Lottie.h>
#import "LAMainView.h"


@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  
}

- (void)viewDidAppear {
  [super viewDidAppear];
}

- (void)viewDidDisappear {
  [super viewDidDisappear];
}

- (IBAction)_sliderChanged:(NSSlider *)sender {
  [(LAMainView *)self.view setAnimationProgress:sender.floatValue];
}

- (IBAction)_rewind:(id)sender {
  [(LAMainView *)self.view rewindAnimation];
}

- (IBAction)_play:(id)sender {
  [(LAMainView *)self.view playAnimation];
}

- (IBAction)_loops:(id)sender {
  [(LAMainView *)self.view toggleLoop];
}

@end
