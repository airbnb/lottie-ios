//
//  NSError+MTLModelException.m
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "MTLModel.h"

#import "NSError+MTLModelException.h"

// The domain for errors originating from MTLModel.
static NSString * const MTLModelErrorDomain = @"MTLModelErrorDomain";

// An exception was thrown and caught.
static const NSInteger MTLModelErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
static NSString * const MTLModelThrownExceptionErrorKey = @"MTLModelThrownException";

@implementation NSError (MTLModelException)

+ (instancetype)mtl_modelErrorWithException:(NSException *)exception {
	NSParameterAssert(exception != nil);

	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: exception.description,
		NSLocalizedFailureReasonErrorKey: exception.reason,
		MTLModelThrownExceptionErrorKey: exception
	};

	return [NSError errorWithDomain:MTLModelErrorDomain code:MTLModelErrorExceptionThrown userInfo:userInfo];
}

@end
