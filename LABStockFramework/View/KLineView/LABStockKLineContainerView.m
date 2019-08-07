//
//  LABStockKLineContainerView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockKLineContainerView.h"
#import "LABStockKLineBgView.h"
#import "LABStockKLineView.h"
#import "LABStockConstant.h"
#import "UIColor+LABStock.h"
#import "LABStockMA.h"
#import "LABStockFormatUtils.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

@interface LABStockKLineContainerView ()

///网格背景
@property (nonatomic, strong) LABStockKLineBgView *bgView;
///K线走势绘图页面
@property (nonatomic, strong) LABStockKLineView *kLineView;

///数据范围,最大最小值
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

///ma指标
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

@end

@implementation LABStockKLineContainerView

#pragma mark --初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.kLineView];
    [self.kLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(self).offset(LABStockScrollViewTopGap);
    }];
}

#pragma mark --外部方法

- (NSArray<LABStockKLinePositionModel *> *)drawViewWithXPosition:(CGFloat)xPosition
                                                      lineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels
                                                      drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                                       drawRange:(NSRange)range
                                                     selectIndex:(NSInteger)index {
    ///求最大最小值
    CGFloat max = [[[drawLineModels valueForKeyPath:@"ms_high"] valueForKeyPath:@"@max.doubleValue"] doubleValue];
    CGFloat min =  [[[drawLineModels valueForKeyPath:@"ms_low"] valueForKeyPath:@"@min.doubleValue"] doubleValue];
    LABStockMA *ma = [[LABStockMA alloc] initWithLineModels:lineModels MATypes:@[@(LABStockMAType5), @(LABStockMAType10), @(LABStockMAType30)]];
    ma.range = range;
    [ma getMaxMin:range];
    
    max = MAX(max, ma.maxValue);
    if (ma.minValue > 0) {
        min = MIN(min, ma.minValue);
    }
    self.accessory = ma;
    
    ///上下扩大一点,比例是上下留的边距LABStockLineMainViewMinY占当前绘制高度(CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2)的比例
    CGFloat scale = (CGFloat)(LABStockLineMainViewMinY/(CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2));
    self.maxValue = max + (max-min)*scale;
    self.minValue = min - (max-min)*scale;
    
    NSString *maxStr = [LABStockFormatUtils getStringWithDouble:self.maxValue andScale:[LABStockVariable pricePrecision]];
    NSString *minStr = [LABStockFormatUtils getStringWithDouble:self.minValue andScale:[LABStockVariable pricePrecision]];
    
    if ([maxStr isEqualToString:minStr]) {
        //处理特殊情况
        if (self.maxValue == 0) {
            self.maxValue = 4.0f;
            self.minValue = 0.0f;
        } else {
            self.maxValue = self.maxValue * 2;
            self.minValue = 0.0f;
        }
    }
    if (self.minValue < 0) {
        self.minValue = 0.0f;
    }
    
    id<LABStockDataProtocol> preModel = nil;
    if (range.location != 0) {//说明不是从0开始
        preModel = lineModels[range.location-1];
    }
    
    [self updateSelectIndex:index];
    return [self.kLineView drawViewWithXPosition:xPosition
                              drawModelsPreModel:preModel
                                      drawModels:drawLineModels
                                        maxValue:self.maxValue
                                        minValue:self.minValue
                                      accecssory:self.accessory];
}

- (void)updateSelectIndex:(NSInteger)index {
    [self.bgView updateSelectIndex:index maxValue:self.maxValue minValue:self.minValue accecssory:self.accessory];
}

#pragma mark --懒加载,getter

- (LABStockKLineBgView *)bgView {
    if (!_bgView) {
        _bgView = [LABStockKLineBgView new];
        _bgView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgView;
}

- (LABStockKLineView *)kLineView {
    if (!_kLineView) {
        _kLineView = [LABStockKLineView new];
        _kLineView.backgroundColor = [UIColor clearColor];
    }
    return _kLineView;
}


@end
