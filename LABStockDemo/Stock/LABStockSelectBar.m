//
//  LABStockSelectBar.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockSelectBar.h"
#import <Masonry/Masonry.h>

@interface LABStockSelectBar ()

@property (nonatomic, strong) MASConstraint *indicatorX;

@end

@implementation LABStockSelectBar

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initUI];
}

- (void)initUI {
    ///初始化指示器
    UIView *indicatorView = [UIView new];
    indicatorView.backgroundColor = [UIColor colorWithR:0.0f g:122.0f b:255.0f a:1.0];
    [self addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@2);
        make.width.equalTo(@25);
        make.bottom.equalTo(self);
    }];
    LABStockType defaultType = [LABStockVariable curStockType];
    [self upDateUI:defaultType];
}

- (void)upDateUI:(LABStockType)type {
    NSAssert(NO, @"子类实现, 不需要调用super");
}

- (void)updateIndicatorView:(UIButton *)btn {
    if (self.indicatorX) {
        [self.indicatorX uninstall];
        self.indicatorX = nil;
    }
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.indicatorX = make.centerX.equalTo(btn);
    }];
}

- (void)hiddenMoreView {
    NSAssert(NO, @"子类实现");
}

@end
