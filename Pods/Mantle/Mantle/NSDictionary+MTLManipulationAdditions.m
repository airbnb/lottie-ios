//
//  NSDictionary+MTLManipulationAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSDictionary+MTLManipulationAdditions.h"

@implementation NSDictionary (MTLManipulationAdditions)

- (NSDictionary *)mtl_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
	NSMutableDictionary *result = [self mutableCopy];
	[result addEntriesFromDictionary:dictionary];
	return result;
}

- (NSDictionary *)mtl_dictionaryByRemovingValuesForKeys:(NSArray *)keys {
	NSMutableDictionary *result = [self mutableCopy];
	[result removeObjectsForKeys:keys];
	return result;
}

@end

@implementation NSDictionary (MTLManipulationAdditions_Deprecated)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

- (NSDictionary *)mtl_dictionaryByRemovingEntriesWithKeys:(NSSet *)keys {
	return [self mtl_dictionaryByRemovingValuesForKeys:keys.allObjects];
}

#pragma clang diagnostic pop

@end
