/*
 *  Copyright (c) 2015, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <FBSnapshotTestCase/UIApplication+StrictKeyWindow.h>

@implementation UIApplication (StrictKeyWindow)

- (UIWindow *)fb_strictKeyWindow
{
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  if (!keyWindow) {
    [NSException raise:@"FBSnapshotTestCaseNilKeyWindowException"
                format:@"Snapshot tests must be hosted by an application with a key window. Please ensure your test"
                        " host sets up a key window at launch (either via storyboards or programmatically) and doesn't"
                        " do anything to remove it while snapshot tests are running."];
  }
  return keyWindow;
}

@end
