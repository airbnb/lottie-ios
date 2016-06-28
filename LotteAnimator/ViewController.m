//
//  ViewController.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"
#import "LAJSONExplorerViewController.h"





@interface ViewController ()

@property (nonatomic, strong) UIButton *openButton;
@property (nonatomic, strong) LAScene *currentScene;
@property (nonatomic, strong) UIView *currentSceneView;
@property (nonatomic, strong) UIView *logView;
@property (nonatomic, strong) UITextView *logTextField;
@property (nonatomic, strong) UIButton *openLogButton;
@property (nonatomic, strong) UIButton *closeLogButton;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.logTextField = [[UITextView alloc] initWithFrame:self.logView.bounds];
  self.logTextField.textColor = [UIColor greenColor];
  self.logTextField.backgroundColor = [UIColor darkGrayColor];
  self.logTextField.font = [UIFont boldSystemFontOfSize:18];
  self.logTextField.text = @"LOTTE ANIMATOR";
  
//  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
//  [self openFileURL:filePath];
  self.openButton = [UIButton  buttonWithType:UIButtonTypeSystem];
  [self.openButton setTitle:@"Open Comp" forState:UIControlStateNormal];
  
  [self.openButton addTarget:self action:@selector(_openButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  self.openButton.layer.cornerRadius = 2;
  self.openButton.layer.borderWidth = 2;
  self.openButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.openButton.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.openButton];
  
  self.openLogButton = [UIButton  buttonWithType:UIButtonTypeSystem];
  [self.openLogButton setTitle:@"Log" forState:UIControlStateNormal];
  self.openLogButton.frame = CGRectMake(0, self.view.bounds.size.height - 60, 120, 44);
  self.openLogButton.layer.cornerRadius = 2;
  self.openLogButton.backgroundColor = [UIColor whiteColor];
  self.openLogButton.layer.borderWidth = 2;
  self.openLogButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
  [self.openLogButton addTarget:self action:@selector(_openLogButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.openLogButton];
  
  self.closeLogButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.closeLogButton.frame = self.view.bounds;
  [self.closeLogButton addTarget:self action:@selector(_closeLog) forControlEvents:UIControlEventTouchUpInside];
  self.closeLogButton.hidden = YES;
  [self.view addSubview:self.closeLogButton];
  
  self.logView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 0.3, self.view.bounds.size.width, self.view.bounds.size.height * 0.7)];
  self.logView.backgroundColor = [UIColor blackColor];
  self.logView.transform = CGAffineTransformMakeTranslation(0, self.logView.bounds.size.height);
  [self.view addSubview:self.logView];
  
  [self.logView addSubview:self.logTextField];
  
  UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
  testView.backgroundColor = [UIColor whiteColor];
//
  UIBezierPath *startPath = [UIBezierPath new];
  [startPath moveToPoint:CGPointMake(10, 10)];
  [startPath addCurveToPoint:CGPointMake(300, 300) controlPoint1:CGPointMake(300, 0) controlPoint2:CGPointMake(0, 300)];
  startPath.lineWidth = 10;

  UIBezierPath *midPath = [UIBezierPath new];
  [midPath moveToPoint:CGPointMake(50, 10)];
  [midPath addCurveToPoint:CGPointMake(300, 300) controlPoint1:CGPointMake(0, 300) controlPoint2:CGPointMake(300, 0)];
  midPath.lineWidth = 10;
  
  UIBezierPath *endPath = [UIBezierPath new];
  [endPath moveToPoint:CGPointMake(70, 250)];
  [endPath addCurveToPoint:CGPointMake(300, 300) controlPoint1:CGPointMake(0, 300) controlPoint2:CGPointMake(300, 0)];
  endPath.lineWidth = 10;
  
  UIBezierPath *finalPath = [UIBezierPath new];
  [finalPath moveToPoint:CGPointMake(150, 200)];
  [finalPath addCurveToPoint:CGPointMake(150, 100) controlPoint1:CGPointMake(100, 200) controlPoint2:CGPointMake(100, 100)];
  [finalPath addCurveToPoint:CGPointMake(150, 200) controlPoint1:CGPointMake(200, 100) controlPoint2:CGPointMake(200, 200)];
  finalPath.lineWidth = 10;

  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.fillColor = nil;
  shapeLayer.path = startPath.CGPath;
  shapeLayer.strokeColor = [UIColor blueColor].CGColor;
  shapeLayer.frame = testView.bounds;
  shapeLayer.lineWidth = 10;
  [self.view addSubview:testView];
  [testView.layer addSublayer:shapeLayer];
  
//  CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
//  animation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(150, 150)];
//  animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(300, 300)];
//  animation1.fillMode = kCAFillModeForwards;
//  animation1.duration = 1;
//  
//  
//  CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
//  animation2.fromValue = animation1.toValue;
//  animation2.toValue = [NSValue valueWithCGPoint:CGPointMake(500, 300)];
//  animation2.duration = 1;
//  animation2.fillMode = kCAFillModeForwards;
//  animation2.beginTime = 2;
//  
//  CAAnimationGroup *group = [CAAnimationGroup new];
//  group.animations = @[animation1, animation2];
//  group.duration = 3;
//  group.beginTime = CACurrentMediaTime() + 3;
//  group.removedOnCompletion = NO;
//  group.fillMode = kCAFillModeForwards;
//  group.repeatCount = HUGE_VALF;
//  group.autoreverses = YES;
//  
//  [shapeLayer addAnimation:group forKey:@"keyframeTest"];
  
  
//
  CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
  keyframeAnimation.values = @[(id)startPath.CGPath, (id)midPath.CGPath, (id)endPath.CGPath, (id)finalPath.CGPath, (id)finalPath.CGPath];
  keyframeAnimation.keyTimes = @[@0.1,                  @0.25,              @0.5,               @0.9,                   @1];
  keyframeAnimation.duration = 1;
  keyframeAnimation.repeatCount = HUGE_VALF;
  keyframeAnimation.autoreverses = YES;
  keyframeAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
  keyframeAnimation.beginTime = CACurrentMediaTime() + 5;
  [shapeLayer addAnimation:keyframeAnimation forKey:@"keyframeTest"];
  
  
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.openButton.frame = CGRectMake(20, self.view.bounds.size.height - 60, 120, 44);
  self.openLogButton.frame = CGRectAttachedRightToRect(self.openButton.frame, CGSizeMake(120, 44), 10, YES);
  
  CGAffineTransform xform = self.logView.transform;
  self.logView.transform = CGAffineTransformIdentity;
  self.logView.frame = CGRectMake(0, self.view.bounds.size.height * 0.3, self.view.bounds.size.width, self.view.bounds.size.height * 0.7);
  self.logTextField.frame = self.logView.bounds;
  self.logView.transform = xform;
  
  self.closeLogButton.frame = self.view.bounds;
  
}

- (void)_openButtonPressed {
  LAJSONExplorerViewController *vc = [[LAJSONExplorerViewController alloc] init];
  __weak typeof(self) weakSelf = self;
  [vc setCompletionBlock:^(NSString *fileURL) {
    __strong typeof(self) strongSelf = weakSelf;
    if (fileURL) {
      [strongSelf openFileURL:fileURL];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
  }];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:navController animated:YES completion:NULL];
}

- (void)_openLogButtonPressed {
  [UIView animateWithDuration:0.3 animations:^{
    self.logView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    self.closeLogButton.hidden = NO;
  }];
}

- (void)_closeLog {
  [UIView animateWithDuration:0.3 animations:^{
    self.logView.transform =  CGAffineTransformMakeTranslation(0, self.logView.bounds.size.height);
  } completion:^(BOOL finished) {
    self.closeLogButton.hidden = YES;
  }];
}

- (void)appendStringToLog:(NSString *)string {
  NSString *currentString = self.logTextField.text.length ?  self.logTextField.text : @"";
  self.logTextField.text = [currentString stringByAppendingString:[NSString stringWithFormat:@"\n%@", string]];
  [self.logTextField setContentOffset:CGPointMake(0, self.logTextField.contentSize.height - self.logTextField.bounds.size.height)];
}

- (void)openFileURL:(NSString *)filePath {
  [self.currentSceneView removeFromSuperview];
  self.currentSceneView = nil;
  self.currentScene = nil;
  NSError *error;
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0 error:&error];
  
  NSDictionary *object = [JSONObject objectForKey:@"animation"];

  LAScene *laScene = [MTLJSONAdapter modelOfClass:[LAScene class] fromJSONDictionary:JSONObject error:&error];
  [self appendStringToLog:@"\n\nOPENING NEW FILE\n"];
  if (error) {
    [self appendStringToLog:[NSString stringWithFormat:@"Failed to open %@", filePath]];
    [self appendStringToLog:error.description];
  } else {

//    NSArray *array = [laScene.description componentsSeparatedByString:@"\\n"];
    
    
    [self appendStringToLog:[NSString stringWithFormat:@"Successfully opened %@", filePath]];
    [self appendStringToLog:JSONObject.description];
//    for (NSString *string in array) {
//      [self appendStringToLog:string];
//    }
  }
  
//  LACompView *compView = [[LACompView alloc] initWithModel:laScene];
//  
//  [self.view addSubview:compView];
//  self.currentScene = laScene;
//  self.currentSceneView = compView;
//  [self.view sendSubviewToBack:self.currentSceneView];
}
@end
