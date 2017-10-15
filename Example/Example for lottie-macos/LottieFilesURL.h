//
//  LottieFilesUrl.h
//  lottie-ios
//
//  Created by Fabio Nuno on 06/08/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LottieFilesURL : NSObject

- (nullable instancetype)initWithURL:(nonnull NSURL *)url;

@property (nonatomic, readonly) int ID;
@property (nonatomic, nonnull, readonly) NSURL *baseURL;
@property (nonatomic, nonnull, readonly) NSURL *jsonURL;
@property (nonatomic, nonnull, readonly) NSString *animationName;

+(BOOL)isValidURL:(nonnull NSURL *)url;

@end
