//
//  LABStockProtraitView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockProtraitView.h"
#import "LABStockProtraitQuoteView.h"
#import "LABStockSelectBarProtrait.h"
#import "LABStock.h"
#import "LABStcokSelectMaskView.h"
#import "LABStockDataTools.h"
#import <Masonry/Masonry.h>

@interface LABStockProtraitView ()<LABStockSelectBarDelegate, LABStockDelegate, LABStockDataSource>

///报价盘
@property (nonatomic, strong) LABStockProtraitQuoteView *quoteView;
///分时K线类型选择条
@property (nonatomic, strong) LABStockSelectBarProtrait *selectBarView;
///分时K线绘图
@property (nonatomic, strong) LABStock *labStock;
///选中数据展示的遮罩
@property (nonatomic, strong) LABStcokSelectMaskView *selectMaskView;

@end

@implementation LABStockProtraitView

#pragma mark --初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

#pragma mark --外部方法

- (void)start {
    ///开始网络请求数据等
    [LABStockDataTools queryStockDataForKey:@"888888" stockType:[LABStockVariable curStockType] completed:^{
        [self.labStock draw];
    }];
    [LABStockDataTools queryStockQuoteForKey:@"888888" stockType:[LABStockVariable curStockType] completed:^(LABStockQuoteViewData * _Nonnull quoteData) {
        [self.quoteView setData:quoteData];
    }];
}

- (void)refresh {
    [self.selectBarView upDateUI:[LABStockVariable curStockType]];
    [self.labStock selectedStockType:[LABStockVariable curStockType]];
}

+ (CGFloat)getViewHeight {
    return 90 + 30 + 350 + 20;
}

#pragma mark --内部方法

- (void)initUI {
    self.backgroundColor = [UIColor LABStock_stockBgColor];
    [self addSubview:self.quoteView];
    [self.quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(90));
    }];
    [self addSubview:self.selectBarView];
    [self.selectBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.quoteView.mas_bottom);
        make.height.equalTo(@(30));
    }];
    [self addSubview:self.labStock.containerView];
    [self.labStock.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-10);
        make.top.equalTo(self.selectBarView.mas_bottom).offset(10);
        make.height.equalTo(@(350));
    }];
    [self addSubview:self.selectMaskView];
    [self.selectMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.selectBarView);
        make.height.equalTo(@(40));
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.labStock draw];
    });
}

#pragma mark --懒加载,getter

- (LABStockProtraitQuoteView *)quoteView {
    if (!_quoteView) {
        _quoteView = [[NSBundle mainBundle] loadNibNamed:@"LABStockProtraitQuoteView" owner:nil options:nil].firstObject;
        _quoteView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _quoteView;
}

- (LABStockSelectBarProtrait *)selectBarView {
    if (!_selectBarView) {
        _selectBarView = [[NSBundle mainBundle] loadNibNamed:@"LABStockSelectBarProtrait" owner:nil options:nil].firstObject;
        _selectBarView.backgroundColor = [UIColor LABStock_bgColor];
        _selectBarView.delegate = self;
    }
    return _selectBarView;
}

- (LABStock *)labStock {
    if (!_labStock) {
        _labStock = [[LABStock alloc] initWithFrame:self.bounds dataSource:self delegate:self direction:LABScreenDirectionProtrait];
    }
    return _labStock;
}

- (LABStcokSelectMaskView *)selectMaskView {
    if (!_selectMaskView) {
        _selectMaskView = [[NSBundle mainBundle] loadNibNamed:@"LABStcokSelectMaskView" owner:nil options:nil].firstObject;
        _selectMaskView.backgroundColor = [UIColor LABStock_stockBgColor];
        _selectMaskView.hidden = YES;
    }
    return _selectMaskView;
}

#pragma mark --LABStockSelectBarDelegate

- (void)labStockSelectBar:(LABStockSelectBar *)selectBar selectStockType:(LABStockType)type {
    [self.labStock selectedStockType:type];
}

- (void)labStockSelectBar:(LABStockSelectBar *)selectBar selectAccessoryType:(LABAccessoryType)type {
    [self.labStock draw];
}

#pragma mark --LABStockDelegate, LABStockDataSource

- (NSArray<id<LABStockDataProtocol>> *)labStock:(LABStock *)stock stockDataOfType:(LABStockType)type {
    return [LABStockDataTools getStockDataForKey:@"888888" stockType:type];
}

- (void)labStock:(LABStock *)stock longPressSelectedModel:(id<LABStockDataProtocol>)model {
    if (!model) {
        //隐藏遮罩
        self.selectMaskView.hidden = YES;
    }else {
        ///显示上面的遮罩View
        if (self.selectMaskView.hidden) {
            self.selectMaskView.hidden = NO;
        }
        self.selectMaskView.selectmodel = model;
        ///隐藏选择条点击出现的更多view
        [self.selectBarView hiddenMoreView];
    }
}

- (void)labStockDidScaleMax:(LABStock *)stock {
    NSLog(@"已经放大到最大了,不能再放大了");
}

- (void)labStockDidScaleMin:(LABStock *)stock {
    NSLog(@"已经缩小到最小了,不能再缩小了");
}

- (void)labStockDidScrollToHead:(LABStock *)stock {
    NSLog(@"已经滑动最头上了,判断是否可以加载更多历史数据,若有则加载刷新,没有则提示");
}

- (void)labStockDidScrollToTail:(LABStock *)stock {
    NSLog(@"已经滑动最尾了");
}

@end
