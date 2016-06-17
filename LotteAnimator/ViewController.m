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
@property (nonatomic, strong) LACompView *currentSceneView;
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
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
  [self openFileURL:filePath];
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
  
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0 error:NULL];
  
  NSDictionary *object = [JSONObject objectForKey:@"animation"];
  
  NSError *error;
  LAScene *laScene = [MTLJSONAdapter modelOfClass:[LAScene class] fromJSONDictionary:object error:&error];
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
  
  LACompView *compView = [[LACompView alloc] initWithModel:laScene];
  
  [self.view addSubview:compView];
  self.currentScene = laScene;
  self.currentSceneView = compView;
  [self.view sendSubviewToBack:self.currentSceneView];
}
@end
