//
//  LAJSONExplorerViewController.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSONExplorerViewController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(NSString *jsonURL);

@end
