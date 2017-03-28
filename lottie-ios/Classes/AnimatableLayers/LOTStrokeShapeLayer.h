//
//  LOTStrokeShapeLayer.h
//  Pods
//
//  Created by Brandon Withrow on 2/7/17.
//
//

#import <QuartzCore/QuartzCore.h>

@interface LOTStrokeShapeLayer : CAShapeLayer

@property (nonatomic) CGFloat trimStart;
@property (nonatomic) CGFloat trimEnd;
@property (nonatomic) CGFloat trimOffset;

@end
