//
//  NSDictionary+MTLMappingAdditions.m
//  Mantle
//
//  Created by Robert Böhnke on 10/31/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "MTLModel.h"

#import "NSDictionary+MTLMappingAdditions.h"

@implementation NSDictionary (MTLMappingAdditions)

+ (NSDictionary *)mtl_identityPropertyMapWithModel:(Class)modelClass {
	NSCParameterAssert([modelClass isSubclassOfClass:MTLModel.class]);

	NSArray *propertyKeys = [modelClass propertyKeys].allObjects;

	return [NSDictionary dictionaryWithObjects:propertyKeys forKeys:propertyKeys];
}

@end
