//
//  ViewController.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "ViewController.h"
#import "LABStockProtraitView.h"
#import "SecondViewController.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) LABStockProtraitView *stockView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    [self.view addSubview:self.stockView];
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(20);
        }
        make.width.equalTo(self.view);
        make.height.equalTo(@([LABStockProtraitView getViewHeight]));
    }];
    [self.stockView start];
}

- (LABStockProtraitView *)stockView {
    if (!_stockView) {
        _stockView = [[LABStockProtraitView alloc] init];
    }
    return _stockView;
}

- (IBAction)push:(UIBarButtonItem *)sender {
    SecondViewController *to = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SecondViewController"];
    __weak typeof(self) weakSelf = self;
    to.backBlock = ^{
        [weakSelf.stockView refresh];
    };
    [self.navigationController pushViewController:to animated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
