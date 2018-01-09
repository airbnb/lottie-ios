//
//  LADownloadTestViewController.m
//  Lottie-Example
//
//  Created by brandon_withrow on 1/4/18.
//  Copyright © 2018 Brandon Withrow. All rights reserved.
//

// https://upload.wikimedia.org/wikipedia/commons/f/ff/Pizigani_1367_Chart_10MB.jpg

#import "LADownloadTestViewController.h"
#import <Lottie/Lottie.h>

@interface LADownloadTestViewController () <NSURLSessionDownloadDelegate>

@end

@implementation LADownloadTestViewController {
  NSURLSessionDownloadTask *_downloadTask;
  LOTAnimationView *_boatLoader;
  LOTPointInterpolatorCallback *_positionInterpolator;
}

- (void)createDownloadTask {
  NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/f/ff/Pizigani_1367_Chart_10MB.jpg"]];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:[NSOperationQueue mainQueue]];
  _downloadTask = [session downloadTaskWithRequest:downloadRequest];
  [_downloadTask resume];
}

- (void)startDownload:(UIButton *)sender {
  sender.hidden = YES;
  [self createDownloadTask];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];

  // Create Boat Animation
  _boatLoader = [LOTAnimationView animationNamed:@"Boat_Loader"];
  // Set view to full screen, aspectFill
  _boatLoader.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  _boatLoader.contentMode = UIViewContentModeScaleAspectFill;
  _boatLoader.frame = self.view.bounds;
  // Add the Animation
  [self.view addSubview:_boatLoader];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:@"Start Download" forState:UIControlStateNormal];
  [button sizeToFit];
  button.center = self.view.center;
  [button addTarget:self action:@selector(startDownload:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];

  // The center of the screen
  CGPoint screenCenter = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
  // The center one screen height above the screen.
  CGPoint offscreenCenter = CGPointMake(screenCenter.x, -screenCenter.y);

  LOTKeypath *boatKeypath = [LOTKeypath keypathWithString:@"Boat"];

  // Convert points into animation view coordinate space.
  CGPoint boatStartPoint = [_boatLoader convertPoint:screenCenter toKeypathLayer:boatKeypath];
  CGPoint boatEndPoint = [_boatLoader convertPoint:offscreenCenter toKeypathLayer:boatKeypath];

  // Set up out interpolator, to be driven by the download callback
  _positionInterpolator = [LOTPointInterpolatorCallback withFromPoint:boatStartPoint toPoint:boatEndPoint];
  // Set the interpolator on the animation view for the Boat.Transform.Position keypath.
  [_boatLoader setValueDelegate:_positionInterpolator forKeypath:[LOTKeypath keypathWithKeys:@"Boat", @"Transform", @"Position", nil]];

  //Play the first portion of the animation on loop until the download finishes.
  _boatLoader.loopAnimation = YES;
  [_boatLoader playFromProgress:0 toProgress:0.5 withCompletion:nil];

  UIButton *closeButton_ = [UIButton buttonWithType:UIButtonTypeSystem];
  [closeButton_ setTitle:@"Close" forState:UIControlStateNormal];
  [closeButton_ addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeButton_];
  CGSize buttonSize = [closeButton_ sizeThatFits:self.view.bounds.size];
  closeButton_.frame = CGRectMake(10, 30, buttonSize.width, 50);
}

- (void)close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)URLSession:(nonnull NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
  // Pause the animation and disable looping.
  [_boatLoader pause];
  _boatLoader.loopAnimation = NO;
  // Speed up animation to finish out the current loop.
  _boatLoader.animationSpeed = 4;
  [_boatLoader playToProgress:0.5 withCompletion:^(BOOL animationFinished) {
    // At this time the animation is at the halfway point. Reset sped to 1 and play through the completion animation.
    _boatLoader.animationSpeed = 1;
    [_boatLoader playToProgress:1 withCompletion:nil];
  }];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  _positionInterpolator.currentProgress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
}

@end
