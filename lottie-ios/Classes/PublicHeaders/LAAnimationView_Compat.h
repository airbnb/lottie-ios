//
//  LAAnimationView_Compat.h
//  Lottie
//
//  Created by Oleksii Pavlovskyi on 2/2/17.
//  Copyright (c) 2017 Airbnb. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import <UIKit/UIKit.h>
@compatibility_alias LAView UIView;

#else

#import <AppKit/AppKit.h>
@compatibility_alias LAView NSView;

typedef NS_ENUM(NSInteger, LAViewContentMode) {
    LAViewContentModeScaleToFill,
    LAViewContentModeScaleAspectFit,
    LAViewContentModeScaleAspectFill,
    LAViewContentModeRedraw,
    LAViewContentModeCenter,
    LAViewContentModeTop,
    LAViewContentModeBottom,
    LAViewContentModeLeft,
    LAViewContentModeRight,
    LAViewContentModeTopLeft,
    LAViewContentModeTopRight,
    LAViewContentModeBottomLeft,
    LAViewContentModeBottomRight,
};

#endif

