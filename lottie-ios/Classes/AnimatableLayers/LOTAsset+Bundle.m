//
//  LOTAsset+Bundle.m
//  Pods
//
//  Created by JianweiChenJianwei on 2017/3/6.
//
//

#import "LOTAsset+Bundle.h"

static NSBundle *_sBundle = nil;

@implementation LOTAsset (Bundle)

+ (void)registerBundle:(NSBundle *)bundle{
    _sBundle = bundle;
}

+ (NSBundle *)getRegisterBundle{
    return _sBundle;
}

@end
