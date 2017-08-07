//
//  LottieFilesUrl.m
//  lottie-ios
//
//  Created by Fabio Nuno on 06/08/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LottieFilesURL.h"

@implementation LottieFilesURL

NSString *const LOTTIE_FILES_HOST = @"www.lottiefiles.com";
NSString *const LOTTIE_FILES_DOWNLOAD_URL = @"https://www.lottiefiles.com/download/";

- (nullable instancetype)initWithURL:(nonnull NSURL *)url {
    
    if (![LottieFilesURL isValidURL:url])
        return nil;
    
    self = [super init];
    if (self) {
        _baseURL = url;
        [self _init:[url lastPathComponent]];
    }
    
    return self;
}

+(BOOL)isValidURL:(nonnull NSURL *)url {
    
    if (url == nil)
        return FALSE;
    
    return [url.host isEqualToString:LOTTIE_FILES_HOST];
}

-(void)_init:(NSString *)path {
    
    NSError *error = nil;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:@"^\\d+"
                                              options:0
                                                error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:path
                                                         options:0
                                                           range:NSMakeRange(0, [path length])];
    
    if (match != nil) {
        
        NSString *animationID = [path substringWithRange:[match range]];
        
        //get animation id
        _ID = [animationID intValue];
        
        //get animation name
        _animationName = [[[path substringFromIndex:[match range].length+ 1 ]
         stringByReplacingOccurrencesOfString:@"-" withString:@" "]
                          capitalizedString];
        
        //URL to download JSON content
        _jsonURL = [NSURL URLWithString:[LOTTIE_FILES_DOWNLOAD_URL stringByAppendingString:animationID]];
    }
}

@end
