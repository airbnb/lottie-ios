//
//  ViewController.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:0 error:NULL];
  NSDictionary *object = [JSONObject objectForKey:@"animation"];
  
  NSError *error;
  LAScene *laScene = [MTLJSONAdapter modelOfClass:[LAScene class] fromJSONDictionary:object error:&error];
  
  
  LACompView *compView = [[LACompView alloc] initWithModel:laScene];
  
  [self.view addSubview:compView];
}

@end
