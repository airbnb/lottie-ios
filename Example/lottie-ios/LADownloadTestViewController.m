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
}

- (void)createDownloadTask {
  NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/f/ff/Pizigani_1367_Chart_10MB.jpg"]];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:[NSOperationQueue mainQueue]];
  _downloadTask = [session downloadTaskWithRequest:downloadRequest];
  [_downloadTask resume];
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


  UIButton *closeButton_ = [UIButton buttonWithType:UIButtonTypeSystem];
  [closeButton_ setTitle:@"Close" forState:UIControlStateNormal];
  [closeButton_ addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeButton_];
  CGSize buttonSize = [closeButton_ sizeThatFits:self.view.bounds.size];
  closeButton_.frame = CGRectMake(10, 30, buttonSize.width, 50);


  // Do any additional setup after loading the view.
}

- (void)close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)URLSession:(nonnull NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
  NSLog(@"Download Finished");
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  NSLog(@"Bytes written");
}



@end
