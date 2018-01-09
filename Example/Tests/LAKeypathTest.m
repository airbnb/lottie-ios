//
//  LAKeypathTest.m
//  lottie-ios_Tests
//
//  Created by brandon_withrow on 12/14/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lottie/Lottie.h>

@interface LAKeypathTest : XCTestCase

@property (nonatomic, strong) LOTAnimationView *animationView;


@end

@implementation LAKeypathTest

- (void)setUp {
  [super setUp];
  self.animationView = [LOTAnimationView animationNamed:@"keypathTest"];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testAnimationLoaded {
  XCTAssertNotNil(self.animationView.sceneModel, @"Animation Composition is nil");
}

- (void)testExplicitSearch {
  NSString *searchTerm = @"Shape Layer 1.Shape 1.Path 1";
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithString:searchTerm]];
  XCTAssertTrue((results.count == 1), @"Wrong number of results");
  NSString *firstObject = results.firstObject;
  XCTAssertTrue([searchTerm isEqualToString:firstObject], @"Wrong keypath found");
}

- (void)testFuzzyKeySearch_Shape1 {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"**", @"Shape 1", nil]];
  NSArray *expectedResults = @[@"Shape Layer 1.Shape 1",
                               @"WiggleLayer.Shape 1",
                               @"GroupShapeLayer.Group 1.Shape 1",
                               @"TwoShapeLayer.Shape 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 2.Group 1.Shape 1",
                               @"Precomp.GroupShape.Group 1.Shape 1",
                               @"Precomp.SingleShape.Shape 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 1.Group 1.Shape 1"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testFuzzyKeySearch_Shape1_Path1 {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"**", @"Shape 1", @"Path 1", nil]];
  NSArray *expectedResults = @[@"GroupShapeLayer.Group 1.Shape 1.Path 1",
                               @"Shape Layer 1.Shape 1.Path 1",
                               @"TwoShapeLayer.Shape 1.Path 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 2.Group 1.Shape 1.Path 1",
                               @"Precomp.GroupShape.Group 1.Shape 1.Path 1",
                               @"Precomp.SingleShape.Shape 1.Path 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 1.Group 1.Shape 1.Path 1"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testWildcardKeySearch_Shape1 {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"*", @"Shape 1", nil]];
  NSArray *expectedResults = @[@"Shape Layer 1.Shape 1",
                               @"WiggleLayer.Shape 1",
                               @"TwoShapeLayer.Shape 1"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testCompoundFuzzyKeySearch_Shape1 {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"**", @"Shape 1", @"*", @"Stroke Width", nil]];
  NSArray *expectedResults = @[@"Shape Layer 1.Shape 1.Stroke 1.Stroke Width",
                               @"WiggleLayer.Shape 1.Stroke 1.Stroke Width",
                               @"GroupShapeLayer.Group 1.Shape 1.Stroke 1.Stroke Width",
                               @"TwoShapeLayer.Shape 1.Stroke 1.Stroke Width"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testDoubleFuzzyKeySearch_Shape1 {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"**", @"Group 1", @"**", @"Path 1", nil]];
  NSArray *expectedResults = @[@"Precomp.DoubleGroupShape.TopGroup.Group 2.Group 1.Shape 1.Path 1",
                               @"Precomp.GroupShape.Group 1.Shape 2.Path 1",
                               @"Precomp.GroupShape.Group 1.Shape 1.Path 1",
                               @"GroupShapeLayer.Group 1.Shape 2.Path 1",
                               @"GroupShapeLayer.Group 1.Shape 1.Path 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 1.Group 1.Shape 2.Path 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 1.Group 1.Shape 1.Path 1",
                               @"Precomp.DoubleGroupShape.TopGroup.Group 2.Group 1.Shape 2.Path 1"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testKeySearch_Precomp {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"Precomp", nil]];
  NSArray *expectedResults = @[@"Precomp"];

  NSSet *set1 = [NSSet setWithArray:results];
  NSSet *set2 = [NSSet setWithArray:expectedResults];
  XCTAssertTrue([set1 isEqualToSet:set2], @"Wrong keypath found");
}

- (void)testFuzzyKeySearch_Precomp {
  NSArray *results = [self.animationView keysForKeyPath:[LOTKeypath keypathWithKeys:@"Precomp", @"**", nil]];
  XCTAssertTrue((results.count == 33), @"Wrong number of results Sorry");
}

@end
