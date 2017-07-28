//
//  LAQRScannerViewController.h
//  lottie-ios
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAQRScannerViewController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(NSString *jsonURL);

@end
