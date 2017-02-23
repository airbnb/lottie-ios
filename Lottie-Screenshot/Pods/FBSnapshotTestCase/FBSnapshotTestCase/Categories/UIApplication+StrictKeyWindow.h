/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

@interface UIApplication (StrictKeyWindow)

/**
  @return The receiver's @c keyWindow. Raises an assertion if @c nil.
 */
- (UIWindow *)fb_strictKeyWindow;

@end
