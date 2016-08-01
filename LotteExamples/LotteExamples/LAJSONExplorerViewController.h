//
//  LAJSONExplorerViewController.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LAJSONExplorerViewController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(NSString *jsonURL);

@end
