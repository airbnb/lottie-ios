//
//  EXTKeyPathCoding.h
//  extobjc
//
//  Created by Justin Spahr-Summers on 19.06.12.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import <Foundation/Foundation.h>
#import "metamacros.h"

/**
 * \@keypath allows compile-time verification of key paths. Given a real object
 * receiver and key path:
 *
 * @code

NSString *UTF8StringPath = @keypath(str.lowercaseString.UTF8String);
// => @"lowercaseString.UTF8String"

NSString *versionPath = @keypath(NSObject, version);
// => @"version"

NSString *lowercaseStringPath = @keypath(NSString.new, lowercaseString);
// => @"lowercaseString"

 * @endcode
 *
 * ... the macro returns an \c NSString containing all but the first path
 * component or argument (e.g., @"lowercaseString.UTF8String", @"version").
 *
 * In addition to simply creating a key path, this macro ensures that the key
 * path is valid at compile-time (causing a syntax error if not), and supports
 * refactoring, such that changing the name of the property will also update any
 * uses of \@keypath.
 */
#define keypath(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))

#define keypath1(PATH) \
    (((void)(NO && ((void)PATH, NO)), strchr(# PATH, '.') + 1))

#define keypath2(OBJ, PATH) \
    (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

/**
 * \@collectionKeypath allows compile-time verification of key paths across collections NSArray/NSSet etc. Given a real object
 * receiver, collection object receiver and related keypaths:
 *
 * @code
 
 NSString *employeesFirstNamePath = @collectionKeypath(department.employees, Employee.new, firstName)
 // => @"employees.firstName"
 
 NSString *employeesFirstNamePath = @collectionKeypath(Department.new, employees, Employee.new, firstName)
 // => @"employees.firstName"

 * @endcode
 *
 */
#define collectionKeypath(...) \
    metamacro_if_eq(3, metamacro_argcount(__VA_ARGS__))(collectionKeypath3(__VA_ARGS__))(collectionKeypath4(__VA_ARGS__))

#define collectionKeypath3(PATH, COLLECTION_OBJECT, COLLECTION_PATH) ([[NSString stringWithFormat:@"%s.%s",keypath(PATH), keypath(COLLECTION_OBJECT, COLLECTION_PATH)] UTF8String])

#define collectionKeypath4(OBJ, PATH, COLLECTION_OBJECT, COLLECTION_PATH) ([[NSString stringWithFormat:@"%s.%s",keypath(OBJ, PATH), keypath(COLLECTION_OBJECT, COLLECTION_PATH)] UTF8String])

