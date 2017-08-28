//
//  LOTAnimatedSwitch.m
//  Lottie
//
//  Created by brandon_withrow on 8/25/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTAnimatedSwitch.h"
#import "LOTAnimationView.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTAnimatedSwitch {
  CGFloat _onStartProgress;
  CGFloat _onEndProgress;
  CGFloat _offStartProgress;
  CGFloat _offEndProgress;
  BOOL _on;
}

/// Convenience method to initialize a control from the Main Bundle by name
+ (instancetype _Nonnull )switchNamed:(NSString * _Nonnull)toggleName {
  return [LOTAnimatedSwitch switchNamed:toggleName inBundle:[NSBundle mainBundle]];
}

/// Convenience method to initialize a control from the specified bundle by name
+ (instancetype _Nonnull )switchNamed:(NSString * _Nonnull)toggleName inBundle:(NSBundle * _Nonnull)bundle {
  LOTComposition *composition = [LOTComposition animationNamed:toggleName inBundle:bundle];
  LOTAnimatedSwitch *animatedControl = [[LOTAnimatedSwitch alloc] initWithFrame:CGRectZero];
  if (composition) {
    [animatedControl setAnimationComp:composition];
    animatedControl.bounds = composition.compBounds;
  }
  return animatedControl;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _onStartProgress = 0;
    _onEndProgress = 1;
    _offStartProgress = 1;
    _offEndProgress = 0;
    _on = NO;
    [self addTarget:self action:@selector(_toggle) forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)setAnimationComp:(LOTComposition *)animationComp {
  [super setAnimationComp:animationComp];
  [self setOn:_on animated:NO];
}

#pragma mark - External Methods

- (void)setProgressRangeForOnState:(CGFloat)fromProgress toProgress:(CGFloat)toProgress {
  _onStartProgress = fromProgress;
  _onEndProgress = toProgress;
  [self setOn:_on animated:NO];
}

- (void)setProgressRangeForOffState:(CGFloat)fromProgress toProgress:(CGFloat)toProgress {
  _offStartProgress = fromProgress;
  _offEndProgress = toProgress;
  [self setOn:_on animated:NO];
}

- (void)setOn:(BOOL)on {
  [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
  if (_on == on) {
    animated = NO;
  }
  
  _on = on;
  
  CGFloat startProgress = on ? _onStartProgress : _offStartProgress;
  CGFloat endProgress = on ? _onEndProgress : _offEndProgress;
  
  if (animated) {
    [self.animationView pause];
    [self.animationView playFromProgress:startProgress toProgress:endProgress withCompletion:nil];
  } else {
    self.animationView.animationProgress = endProgress;
  }
  
}

#pragma mark - Internal Methods

- (void)_toggle {
  if (self.isEnabled) {
    [self setOn:!_on animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

@end
