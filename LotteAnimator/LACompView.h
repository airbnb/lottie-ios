//
//  LACompView.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LACompView : UIView

- (instancetype)initWithModel:(LAComposition *)model;

@property (nonatomic, readonly) LAComposition *sceneModel;
@property (nonatomic, assign) BOOL debugModeOn;

@property (nonatomic, assign) BOOL loopAnimation;
@property (nonatomic, assign) BOOL autoReverseAnimation;
@property (nonatomic, assign) CGFloat animationProgress;

- (void)play;
- (void)pause;

@end
