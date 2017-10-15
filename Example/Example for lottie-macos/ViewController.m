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
#import "LottieFilesURL.h"

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

- (void)paste:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSURL class], nil];
    
    if ([pasteboard canReadObjectForClasses:classes options:nil]) {
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:nil];
        
        if (copiedItems != nil) {
            NSURL *url = (NSURL *)[copiedItems firstObject];
            LottieFilesURL *lottieFile = [[LottieFilesURL alloc] initWithURL:url];
            
            if (lottieFile != nil) {
                [(LAMainView *)self.view openAnimationURL:lottieFile.jsonURL];
                self.view.window.title =  lottieFile.animationName;
            }
        }
    }
}


@end
