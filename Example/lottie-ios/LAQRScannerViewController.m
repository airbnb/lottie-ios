//
//  LAQRScannerViewController.m
//  lottie-ios
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LAQRScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LAQRScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic)  UIView *viewPreview;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation LAQRScannerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(_closePressed)];
  self.viewPreview = [[UIView alloc] initWithFrame:self.view.bounds];
  self.viewPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.viewPreview];
  _isReading = NO;
  
  _captureSession = nil;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!_isReading) {
    _isReading = [self startReading];
  }
}

- (BOOL)startReading {
  NSError *error;
  
  AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
  if (!input) {
    NSLog(@"%@", [error localizedDescription]);
    return NO;
  }
  
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession addInput:input];
  
  AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
  [_captureSession addOutput:captureMetadataOutput];
  
  dispatch_queue_t dispatchQueue;
  dispatchQueue = dispatch_queue_create("myQueue", NULL);
  [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
  [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
  
  if (_videoPreviewLayer) {
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
  }
  _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
  [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
  [_viewPreview.layer addSublayer:_videoPreviewLayer];
  
  [_captureSession startRunning];
  
  return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
  if (metadataObjects != nil && [metadataObjects count] > 0) {
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
      [self performSelectorOnMainThread:@selector(stopReadingWithString:) withObject:[metadataObj stringValue] waitUntilDone:NO];
    }
  }
}

- (void)stopReadingWithString:(NSString *)urlString {
  if (_isReading) {
    _isReading = NO;
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
    if (self.completionBlock) {
      self.completionBlock(urlString);
    }
  }
  
}

- (void)_closePressed {
  [self stopReadingWithString:nil];
}

@end
