//
//  SecondViewController.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "SecondViewController.h"
#import "LABStockLandspaceView.h"
#import <Masonry/Masonry.h>

@interface SecondViewController ()

@property (nonatomic, strong) LABStockLandspaceView *stockView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ///强制横屏
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    ///刷新
    [UIViewController attemptRotationToDeviceOrientation];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)initView {
    [self.view addSubview:self.stockView];
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }else{
            make.edges.equalTo(self.view);
        }
    }];
    [self.stockView start];
}

- (LABStockLandspaceView *)stockView {
    if (!_stockView) {
        _stockView = [[LABStockLandspaceView alloc] init];
        __weak typeof(self) weakSelf = self;
        _stockView.closeBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _stockView;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
