//
//  LOTAsset+Bundle.h
//  Pods
//
//  Created by JianweiChenJianwei on 2017/3/6.
//
//

#import "LOTAsset.h"

@interface LOTAsset (Bundle)

+ (void)registerBundle:(NSBundle *)bundle;

+ (NSBundle *)getRegisterBundle;

@end
