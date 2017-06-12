//
//  LOTAsset+Bundle.m
//  Pods
//
//  Created by JianweiChenJianwei on 2017/3/6.
//
//

#import "LOTContext.h"

static NSBundle *_sBundle = nil;

@implementation LOTContext

+ (void)registerBundle:(NSBundle *)bundle{
    _sBundle = bundle;
}

+ (NSBundle *)getRegisterBundle{
    return _sBundle;
}

@end
