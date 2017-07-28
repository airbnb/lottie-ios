//
//  LOTGradientFillRender.m
//  Lottie
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTGradientFillRender.h"
#import "LOTArrayInterpolator.h"
#import "LOTPointInterpolator.h"
#import "LOTNumberInterpolator.h"
#import "CGGeometry+LOTAdditions.h"
#import "LOTHelpers.h"

@implementation LOTGradientFillRender {
  BOOL _evenOddFillRule;
  CALayer *centerPoint_DEBUG;
  
  CAShapeLayer *_maskShape;
  CAGradientLayer *_gradientOpacityLayer;
  CAGradientLayer *_gradientLayer;
  NSInteger _numberOfPositions;
  
  CGPoint _startPoint;
  CGPoint _endPoint;
  
  LOTArrayInterpolator *_gradientInterpolator;
  LOTPointInterpolator *_startPointInterpolator;
  LOTPointInterpolator *_endPointInterpolator;
  LOTNumberInterpolator *_opacityInterpolator;
}

- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nonnull)inputNode
                          shapeGradientFill:(LOTShapeGradientFill *_Nonnull)fill {
  self = [super initWithInputNode:inputNode];
  if (self) {
    _gradientInterpolator = [[LOTArrayInterpolator alloc] initWithKeyframes:fill.gradient.keyframeGroup.keyframes];
    _startPointInterpolator = [[LOTPointInterpolator alloc] initWithKeyframes:fill.startPoint.keyframeGroup.keyframes];
    _endPointInterpolator = [[LOTPointInterpolator alloc] initWithKeyframes:fill.endPoint.keyframeGroup.keyframes];
    _opacityInterpolator = [[LOTNumberInterpolator alloc] initWithKeyframes:fill.opacity.keyframeGroup.keyframes];
    _numberOfPositions = fill.numberOfColors.integerValue;
    
    _evenOddFillRule = fill.evenOddFillRule;
    CALayer *wrapperLayer = [CALayer new];
    _maskShape = [CAShapeLayer new];
    _maskShape.fillRule = _evenOddFillRule ? @"even-odd" : @"non-zero";
    _maskShape.fillColor = [UIColor whiteColor].CGColor;
    _maskShape.actions = @{@"path": [NSNull null]};
    
    _gradientOpacityLayer = [CAGradientLayer new];
    _gradientOpacityLayer.actions = @{@"startPoint" : [NSNull null],
                                      @"endPoint" : [NSNull null],
                                      @"opacity" : [NSNull null],
                                      @"locations" : [NSNull null],
                                      @"colors" : [NSNull null],
                                      @"bounds" : [NSNull null],
                                      @"anchorPoint" : [NSNull null]};
    _gradientOpacityLayer.mask = _maskShape;
    [wrapperLayer addSublayer:_gradientOpacityLayer];
    
    _gradientLayer = [CAGradientLayer new];
    _gradientLayer.mask = wrapperLayer;
    _gradientLayer.actions = [_gradientOpacityLayer.actions copy];
    [self.outputLayer addSublayer:_gradientLayer];
    
    centerPoint_DEBUG = [CALayer layer];
    centerPoint_DEBUG.bounds = CGRectMake(0, 0, 20, 20);
    if (ENABLE_DEBUG_SHAPES) {
      [self.outputLayer addSublayer:centerPoint_DEBUG];
    }
  }
  return self;
}

- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  return ([_gradientInterpolator hasUpdateForFrame:frame] ||
          [_startPointInterpolator hasUpdateForFrame:frame] ||
          [_endPointInterpolator hasUpdateForFrame:frame] ||
          [_opacityInterpolator hasUpdateForFrame:frame]);
}

- (void)performLocalUpdate {
  centerPoint_DEBUG.backgroundColor =  [UIColor magentaColor].CGColor;
  centerPoint_DEBUG.borderColor = [UIColor lightGrayColor].CGColor;
  centerPoint_DEBUG.borderWidth = 2.f;
  _startPoint = [_startPointInterpolator pointValueForFrame:self.currentFrame];
  _endPoint = [_endPointInterpolator pointValueForFrame:self.currentFrame];
  self.outputLayer.opacity = [_opacityInterpolator floatValueForFrame:self.currentFrame];
  NSArray *numberArray = [_gradientInterpolator numberArrayForFrame:self.currentFrame];
  NSMutableArray *colorArray = [NSMutableArray array];
  NSMutableArray *locationsArray = [NSMutableArray array];
  
  NSMutableArray *opacityArray = [NSMutableArray array];
  NSMutableArray *opacitylocationsArray = [NSMutableArray array];
  for (int i = 0; i < _numberOfPositions; i++) {
    int ix = i * 4;
    NSNumber *location = numberArray[ix];
    NSNumber *r = numberArray[(ix + 1)];
    NSNumber *g = numberArray[(ix + 2)];
    NSNumber *b = numberArray[(ix + 3)];
    [locationsArray addObject:location];
    UIColor *color = [UIColor colorWithRed:r.floatValue green:g.floatValue blue:b.floatValue alpha:1];
    [colorArray addObject:(id)(color.CGColor)];
  }
  for (NSInteger i = (_numberOfPositions * 4); i < numberArray.count; i = i + 2) {
    NSNumber *opacityLocation = numberArray[i];
    [opacitylocationsArray addObject:opacityLocation];
    NSNumber *opacity = numberArray[i + 1];
    UIColor *opacityColor = [UIColor colorWithWhite:1 alpha:opacity.floatValue];
    [opacityArray addObject:(id)(opacityColor.CGColor)];
  }
  _gradientOpacityLayer.locations = opacitylocationsArray;
  _gradientOpacityLayer.colors = opacityArray;
  _gradientLayer.locations = locationsArray;
  _gradientLayer.colors = colorArray;
}

- (void)rebuildOutputs {
  CGRect frame = [self.inputNode.outputPath bounds];
  CGPoint modifiedAnchor = CGPointMake(-frame.origin.x / frame.size.width,
                                       -frame.origin.y / frame.size.height);
  CGPoint modifiedStart = CGPointMake((_startPoint.x - frame.origin.x) / frame.size.width,
                                      (_startPoint.y - frame.origin.y) / frame.size.height);
  CGPoint modifiedEnd = CGPointMake((_endPoint.x - frame.origin.x) / frame.size.width,
                                    (_endPoint.y - frame.origin.y) / frame.size.height);
  _maskShape.path = self.inputNode.outputPath.CGPath;
  _gradientOpacityLayer.bounds = frame;
  _gradientOpacityLayer.anchorPoint = modifiedAnchor;
  _gradientOpacityLayer.startPoint = modifiedStart;
  _gradientOpacityLayer.endPoint = modifiedEnd;
  _gradientLayer.bounds = frame;
  _gradientLayer.anchorPoint = modifiedAnchor;
  _gradientLayer.startPoint = modifiedStart;
  _gradientLayer.endPoint = modifiedEnd;
}

- (NSDictionary *)actionsForRenderLayer {
  return @{@"backgroundColor": [NSNull null],
           @"fillColor": [NSNull null],
           @"opacity" : [NSNull null]};
}

@end
