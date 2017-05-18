//
//  LOTAnimationTransitionController.m
//  Lottie
//
//  Created by Brandon Withrow on 1/18/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import "LOTAnimationTransitionController.h"
#import "LOTAnimationView.h"

@implementation LOTAnimationTransitionController {
  LOTAnimationView *tranistionAnimationView_;
  NSString *fromLayerName_;
  NSString *toLayerName_;
  NSBundle *inBundle_;
}

- (instancetype)initWithAnimationNamed:(NSString *)animation
                        fromLayerNamed:(NSString *)fromLayer
                          toLayerNamed:(NSString *)toLayer {
    
    return [self initWithAnimationNamed:animation
                          fromLayerNamed:fromLayer
                           toLayerNamed:toLayer
                               inBundle:[NSBundle mainBundle]];
}
- (instancetype)initWithAnimationNamed:(NSString *)animation
                        fromLayerNamed:(NSString *)fromLayer
                          toLayerNamed:(NSString *)toLayer
                              inBundle:(NSBundle *)bundle {
  self = [super init];
  if (self) {
    tranistionAnimationView_ = [LOTAnimationView animationNamed:animation inBundle:bundle];
    fromLayerName_ = fromLayer;
    toLayerName_ = toLayer;
  }
  return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return tranistionAnimationView_.animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *containerView = transitionContext.containerView;
  
  UIView *toSnapshot = [toVC.view snapshotViewAfterScreenUpdates:YES];
  toSnapshot.frame = containerView.bounds;
  
  UIView *fromSnapshot = [fromVC.view snapshotViewAfterScreenUpdates:YES];
  fromSnapshot.frame = containerView.bounds;
  
  tranistionAnimationView_.frame = containerView.bounds;
  tranistionAnimationView_.contentMode = UIViewContentModeScaleAspectFill;
  [containerView addSubview:tranistionAnimationView_];
  
  BOOL crossFadeViews = NO;
  
  if (toLayerName_.length) {
    [tranistionAnimationView_ addSubview:toSnapshot toLayerNamed:toLayerName_];
  } else {
    [containerView addSubview:toSnapshot];
    [containerView sendSubviewToBack:toSnapshot];
    toSnapshot.alpha = 0;
    crossFadeViews = YES;
  }
  
  if (fromLayerName_.length) {
    [tranistionAnimationView_ addSubview:fromSnapshot toLayerNamed:fromLayerName_];
  } else {
    [containerView addSubview:fromSnapshot];
    [containerView sendSubviewToBack:fromSnapshot];
  }
  
  [containerView addSubview:toVC.view];
  toVC.view.hidden = YES;
  
  if (crossFadeViews) {
    CGFloat duration = tranistionAnimationView_.animationDuration * 0.25;
    CGFloat delay = (tranistionAnimationView_.animationDuration - duration) / 2.f;
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                       toSnapshot.alpha = 1;
                     } completion:^(BOOL finished) {
                       
                     }];
  }
  
  [tranistionAnimationView_ playWithCompletion:^(BOOL animationFinished) {
    toVC.view.hidden = false;
    [tranistionAnimationView_ removeFromSuperview];
    [transitionContext completeTransition:animationFinished];
  }];
}

@end

#endif
