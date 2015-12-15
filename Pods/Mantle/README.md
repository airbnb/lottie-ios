# Mantle [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Mantle makes it easy to write a simple model layer for your Cocoa or Cocoa Touch
application.

## The Typical Model Object

What's wrong with the way model objects are usually written in Objective-C?

Let's use the [GitHub API](http://developer.github.com) for demonstration. How
would one typically represent a [GitHub
issue](http://developer.github.com/v3/issues/#get-a-single-issue) in
Objective-C?

```objc
typedef enum : NSUInteger {
    GHIssueStateOpen,
    GHIssueStateClosed
} GHIssueState;

@interface GHIssue : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *HTMLURL;
@property (nonatomic, copy, readonly) NSNumber *number;
@property (nonatomic, assign, readonly) GHIssueState state;
@property (nonatomic, copy, readonly) NSString *reporterLogin;
@property (nonatomic, copy, readonly) NSDate *updatedAt;
@property (nonatomic, strong, readonly) GHUser *assignee;
@property (nonatomic, copy, readonly) NSDate *retrievedAt;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
```

```objc
@implementation GHIssue

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self == nil) return nil;

    _URL = [NSURL URLWithString:dictionary[@"url"]];
    _HTMLURL = [NSURL URLWithString:dictionary[@"html_url"]];
    _number = dictionary[@"number"];

    if ([dictionary[@"state"] isEqualToString:@"open"]) {
        _state = GHIssueStateOpen;
    } else if ([dictionary[@"state"] isEqualToString:@"closed"]) {
        _state = GHIssueStateClosed;
    }

    _title = [dictionary[@"title"] copy];
    _retrievedAt = [NSDate date];
    _body = [dictionary[@"body"] copy];
    _reporterLogin = [dictionary[@"user"][@"login"] copy];
    _assignee = [[GHUser alloc] initWithDictionary:dictionary[@"assignee"]];

    _updatedAt = [self.class.dateFormatter dateFromString:dictionary[@"updated_at"]];

    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self == nil) return nil;

    _URL = [coder decodeObjectForKey:@"URL"];
    _HTMLURL = [coder decodeObjectForKey:@"HTMLURL"];
    _number = [coder decodeObjectForKey:@"number"];
    _state = [coder decodeUnsignedIntegerForKey:@"state"];
    _title = [coder decodeObjectForKey:@"title"];
    _retrievedAt = [NSDate date];
    _body = [coder decodeObjectForKey:@"body"];
    _reporterLogin = [coder decodeObjectForKey:@"reporterLogin"];
    _assignee = [coder decodeObjectForKey:@"assignee"];
    _updatedAt = [coder decodeObjectForKey:@"updatedAt"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.URL != nil) [coder encodeObject:self.URL forKey:@"URL"];
    if (self.HTMLURL != nil) [coder encodeObject:self.HTMLURL forKey:@"HTMLURL"];
    if (self.number != nil) [coder encodeObject:self.number forKey:@"number"];
    if (self.title != nil) [coder encodeObject:self.title forKey:@"title"];
    if (self.body != nil) [coder encodeObject:self.body forKey:@"body"];
    if (self.reporterLogin != nil) [coder encodeObject:self.reporterLogin forKey:@"reporterLogin"];
    if (self.assignee != nil) [coder encodeObject:self.assignee forKey:@"assignee"];
    if (self.updatedAt != nil) [coder encodeObject:self.updatedAt forKey:@"updatedAt"];

    [coder encodeUnsignedInteger:self.state forKey:@"state"];
}

- (id)copyWithZone:(NSZone *)zone {
    GHIssue *issue = [[self.class allocWithZone:zone] init];
    issue->_URL = self.URL;
    issue->_HTMLURL = self.HTMLURL;
    issue->_number = self.number;
    issue->_state = self.state;
    issue->_reporterLogin = self.reporterLogin;
    issue->_assignee = self.assignee;
    issue->_updatedAt = self.updatedAt;

    issue.title = self.title;
    issue->_retrievedAt = [NSDate date];
    issue.body = self.body;

    return issue;
}

- (NSUInteger)hash {
    return self.number.hash;
}

- (BOOL)isEqual:(GHIssue *)issue {
    if (![issue isKindOfClass:GHIssue.class]) return NO;

    return [self.number isEqual:issue.number] && [self.title isEqual:issue.title] && [self.body isEqual:issue.body];
}

@end
```

Whew, that's a lot of boilerplate for something so simple! And, even then, there
are some problems that this example doesn't address:

 * There's no way to update a `GHIssue` with new data from the server.
 * There's no way to turn a `GHIssue` _back_ into JSON.
 * `GHIssueState` shouldn't be encoded as-is. If the enum changes in the future,
   existing archives might break.
 * If the interface of `GHIssue` changes down the road, existing archives might
   break.

## Why Not Use Core Data?

Core Data solves certain problems very well. If you need to execute complex
queries across your data, handle a huge object graph with lots of relationships,
or support undo and redo, Core Data is an excellent fit.

It does, however, come with a couple of pain points:

 * **There's still a lot of boilerplate.** Managed objects reduce some of the
   boilerplate seen above, but Core Data has plenty of its own. Correctly
   setting up a Core Data stack (with a persistent store and persistent store
   coordinator) and executing fetches can take many lines of code.
 * **It's hard to get right.** Even experienced developers can make mistakes
   when using Core Data, and the framework is not forgiving.

If you're just trying to access some JSON objects, Core Data can be a lot of
work for little gain.

Nonetheless, if you're using or want to use Core Data in your app already,
Mantle can still be a convenient translation layer between the API and your
managed model objects.

## MTLModel

Enter
**[MTLModel](https://github.com/github/Mantle/blob/master/Mantle/MTLModel.h)**.
This is what `GHIssue` looks like inheriting from `MTLModel`:

```objc
typedef enum : NSUInteger {
    GHIssueStateOpen,
    GHIssueStateClosed
} GHIssueState;

@interface GHIssue : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *HTMLURL;
@property (nonatomic, copy, readonly) NSNumber *number;
@property (nonatomic, assign, readonly) GHIssueState state;
@property (nonatomic, copy, readonly) NSString *reporterLogin;
@property (nonatomic, strong, readonly) GHUser *assignee;
@property (nonatomic, copy, readonly) NSDate *updatedAt;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy, readonly) NSDate *retrievedAt;

@end
```

```objc
@implementation GHIssue

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"URL": @"url",
        @"HTMLURL": @"html_url",
        @"number": @"number",
        @"state": @"state",
        @"reporterLogin": @"user.login",
        @"assignee": @"assignee",
        @"updatedAt": @"updated_at"
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"open": @(GHIssueStateOpen),
        @"closed": @(GHIssueStateClosed)
    }];
}

+ (NSValueTransformer *)assigneeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:GHUser.class];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;

    // Store a value that needs to be determined locally upon initialization.
    _retrievedAt = [NSDate date];

    return self;
}

@end
```

Notably absent from this version are implementations of `<NSCoding>`,
`<NSCopying>`, `-isEqual:`, and `-hash`. By inspecting the `@property`
declarations you have in your subclass, `MTLModel` can provide default
implementations for all these methods.

The problems with the original example all happen to be fixed as well:

> There's no way to update a `GHIssue` with new data from the server.

`MTLModel` has an extensible `-mergeValuesForKeysFromModel:` method, which makes
it easy to specify how new model data should be integrated.

> There's no way to turn a `GHIssue` _back_ into JSON.

This is where reversible transformers really come in handy. `+[MTLJSONAdapter
JSONDictionaryFromModel:error:]` can transform any model object conforming to
`<MTLJSONSerializing>` back into a JSON dictionary. `+[MTLJSONAdapter
JSONArrayFromModels:error:]` is the same but turns an array of model objects into an JSON array of dictionaries.

> If the interface of `GHIssue` changes down the road, existing archives might break.

`MTLModel` automatically saves the version of the model object that was used for
archival. When unarchiving, `-decodeValueForKey:withCoder:modelVersion:` will
be invoked if overridden, giving you a convenient hook to upgrade old data.

## MTLJSONSerializing

In order to serialize your model objects from or into JSON, you need to
implement `<MTLJSONSerializing>` in your `MTLModel` subclass. This allows you to
use `MTLJSONAdapter` to convert your model objects from JSON and back:

```objc
NSError *error = nil;
XYUser *user = [MTLJSONAdapter modelOfClass:XYUser.class fromJSONDictionary:JSONDictionary error:&error];
```

```objc
NSError *error = nil;
NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:user error:&error];
```

### `+JSONKeyPathsByPropertyKey`

The dictionary returned by this method specifies how your model object's
properties map to the keys in the JSON representation, for example:

```objc

@interface XYUser : MTLModel

@property (readonly, nonatomic, copy) NSString *name;
@property (readonly, nonatomic, strong) NSDate *createdAt;

@property (readonly, nonatomic, assign, getter = isMeUser) BOOL meUser;
@property (readonly, nonatomic, strong) XYHelper *helper;

@end

@implementation XYUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"name": @"name",
        @"createdAt": @"created_at"
    };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;

    _helper = [XYHelper helperWithName:self.name createdAt:self.createdAt];

    return self;
}

@end
```

In this example, the `XYUser` class declares four properties that Mantle
handles in different ways:

- `name` is mapped to a key of the same name in the JSON representation.
- `createdAt` is converted to its snake case equivalent.
- `meUser` is not serialized into JSON.
- `helper` is initialized exactly once after JSON deserialization.

Use `-[NSDictionary mtl_dictionaryByAddingEntriesFromDictionary:]` if your
model's superclass also implements `MTLJSONSerializing` to merge their mappings.

If you'd like to map all properties of a Model class to themselves, you can use
the `+[NSDictionary mtl_identityPropertyMapWithModel:]` helper method.

When deserializing JSON using
`+[MTLJSONAdapter modelOfClass:fromJSONDictionary:error:]`, JSON keys that don't
correspond to a property name or have an explicit mapping are ignored:

```objc
NSDictionary *JSONDictionary = @{
    @"name": @"john",
    @"created_at": @"2013/07/02 16:40:00 +0000",
    @"plan": @"lite"
};

XYUser *user = [MTLJSONAdapter modelOfClass:XYUser.class fromJSONDictionary:JSONDictionary error:&error];
```

Here, the `plan` would be ignored since it neither matches a property name of
`XYUser` nor is it otherwise mapped in `+JSONKeyPathsByPropertyKey`.

### `+JSONTransformerForKey:`

Implement this optional method to convert a property from a different type when
deserializing from JSON.

```
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"createdAt"]) {
        return [NSValueTransformer valueTransformerForName:XYDateValueTransformerName];
    }

    return nil;
}
```

For added convenience, if you implement `+<key>JSONTransformer`,
`MTLJSONAdapter` will use the result of that method instead. For example, dates
that are commonly represented as strings in JSON can be transformed to `NSDate`s
like so:

```objc
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}
```

If the transformer is reversible, it will also be used when serializing the
object into JSON.

### `+classForParsingJSONDictionary:`

If you are implementing a class cluster, implement this optional method to
determine which subclass of your base class should be used when deserializing an
object from JSON.

```objc
@interface XYMessage : MTLModel

@end

@interface XYTextMessage: XYMessage

@property (readonly, nonatomic, copy) NSString *body;

@end

@interface XYPictureMessage : XYMessage

@property (readonly, nonatomic, strong) NSURL *imageURL;

@end

@implementation XYMessage

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    if (JSONDictionary[@"image_url"] != nil) {
        return XYPictureMessage.class;
    }

    if (JSONDictionary[@"body"] != nil) {
        return XYTextMessage.class;
    }

    NSAssert(NO, @"No matching class for the JSON dictionary '%@'.", JSONDictionary);
    return self;
}

@end
```

`MTLJSONAdapter` will then pick the class based on the JSON dictionary you pass
in:

```objc
NSDictionary *textMessage = @{
    @"id": @1,
    @"body": @"Hello World!"
};

NSDictionary *pictureMessage = @{
    @"id": @2,
    @"image_url": @"http://example.com/lolcat.gif"
};

XYTextMessage *messageA = [MTLJSONAdapter modelOfClass:XYMessage.class fromJSONDictionary:textMessage error:NULL];

XYPictureMessage *messageB = [MTLJSONAdapter modelOfClass:XYMessage.class fromJSONDictionary:pictureMessage error:NULL];
```

## Persistence

Mantle doesn't automatically persist your objects for you. However, `MTLModel`
does conform to `<NSCoding>`, so model objects can be archived to disk using
`NSKeyedArchiver`.

If you need something more powerful, or want to avoid keeping your whole model
in memory at once, Core Data may be a better choice.

## System Requirements

Mantle supports OS X 10.9+ and iOS 8.0+.

## Importing Mantle

To add Mantle to your application:

 1. Add the Mantle repository as a submodule of your application's repository.
 1. Run `script/bootstrap` from within the Mantle folder.
 1. Drag and drop `Mantle.xcodeproj` into your application's Xcode project. Unfortunately, an [Xcode bug](http://www.openradar.appspot.com/19676555) means you should probably not add it to a workspace.
 1. On the "General" tab of your application target, add `Mantle.framework` to the "Embedded Binaries".

[Carthage](https://github.com/Carthage/Carthage) users can simply add Mantle to their `Cartfile`:
```
github "Mantle/Mantle"
```

If you would prefer to use [CocoaPods](http://cocoapods.org), there are some
[Mantle podspecs](https://github.com/CocoaPods/Specs/tree/master/Specs/Mantle) that
have been generously contributed by third parties.

If you’re instead developing Mantle on its own, use the `Mantle.xcworkspace` file.

## License

Mantle is released under the MIT license. See
[LICENSE.md](https://github.com/github/Mantle/blob/master/LICENSE.md).

## More Info

Have a question? Please [open an issue](https://github.com/Mantle/Mantle/issues/new)!
