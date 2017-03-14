//
//  LottieRootViewController.m
//  LottieExamples
//
//  Created by brandon_withrow on 1/25/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LottieRootViewController.h"
#import <Lottie/Lottie.h>

@interface LottieRootViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet LOTAnimationView *lottieLogo;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tableViewItems;

@end

@implementation LottieRootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self _buildDataSource];
  self.lottieLogo.animationName = @"LottieLogo1";
  self.lottieLogo.contentMode = UIViewContentModeScaleAspectFill;
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_playLottieAnimation)];
  [self.lottieLogo addGestureRecognizer:tap];
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
  [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.lottieLogo play];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self.lottieLogo pause];
}

#pragma mark - Internal Methods

- (void)_buildDataSource {
  self.tableViewItems = @[@{@"name" : @"Animation Explorer",
                            @"vc" : @"AnimationExplorerViewController"},
                          @{@"name" : @"Animated Keyboard",
                            @"vc" : @"TypingDemoViewController"},
                          @{@"name" : @"Animated Transitions Demo",
                            @"vc" : @"AnimationTransitionViewController"}];
}

- (void)_playLottieAnimation {
  self.lottieLogo.animationProgress = 0;
  [self.lottieLogo play];
}

#pragma mark - UITableViewDataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  cell.textLabel.text = self.tableViewItems[indexPath.row][@"name"];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *vcClassName = self.tableViewItems[indexPath.row][@"vc"];
  Class vcClass = NSClassFromString(vcClassName);
  if (vcClass) {
    UIViewController *vc = [[vcClass alloc] init];
    [self presentViewController:vc animated:YES completion:NULL];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
