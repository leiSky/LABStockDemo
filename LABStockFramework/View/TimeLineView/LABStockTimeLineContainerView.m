//
//  LABStockTimeLineContainerView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeLineContainerView.h"
#import "LABStockTimeLineBgView.h"
#import "LABStockTimeLineView.h"
#import "LABStockMA.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import "LABStockFormatUtils.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

@interface LABStockTimeLineContainerView ()

///网格背景
@property (nonatomic, strong) LABStockTimeLineBgView *bgView;
///分时走势绘图页面
@property (nonatomic, strong) LABStockTimeLineView *timeLineView;

///数据范围,最大最小值
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

///ma指标
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

@end

@implementation LABStockTimeLineContainerView

#pragma mark --初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

///初始化子布局
- (void)initUI {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.timeLineView];
    [self.timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self).offset(LABStockScrollViewTopGap);
    }];
}

#pragma mark --懒加载,getter

- (LABStockTimeLineBgView *)bgView {
    if (!_bgView) {
        _bgView = [LABStockTimeLineBgView new];
        _bgView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgView;
}

- (LABStockTimeLineView *)timeLineView {
    if (!_timeLineView) {
        _timeLineView = [LABStockTimeLineView new];
        _timeLineView.backgroundColor = [UIColor clearColor];
    }
    return _timeLineView;
}

#pragma mark --外部方法

- (NSArray<NSValue *> *)drawViewWithXPosition:(CGFloat)xPosition
                                   lineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels
                                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                    drawRange:(NSRange)range
                                  selectIndex:(NSInteger)index {
    ///求最大最小值(分时线中的)
    CGFloat max = [[[drawLineModels valueForKeyPath:@"ms_close"] valueForKeyPath:@"@max.doubleValue"] doubleValue];
    CGFloat min =  [[[drawLineModels valueForKeyPath:@"ms_close"] valueForKeyPath:@"@min.doubleValue"] doubleValue];
    
    ///求最大最小值(指标中的)
    LABStockMA *ma = [[LABStockMA alloc] initWithLineModels:lineModels MATypes:@[@(LABStockMAType5)]];
    ma.range = range;
    [ma getMaxMin:range];
    
    ///综合最大最小(分时和指标中最大最小)
    max = MAX(max, ma.maxValue);
    min = MIN(min, ma.minValue);
    self.accessory = ma;
    
    ///上下扩大一点,比例是上下留的边距LABStockLineMainViewMinY占当前绘制高度(CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2)的比例
    CGFloat scale = (CGFloat)(LABStockLineMainViewMinY/(CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2));
    self.maxValue = max + (max-min)*scale;
    self.minValue = min - (max-min)*scale;
    
    NSString *maxStr = [LABStockFormatUtils getStringWithDouble:self.maxValue andScale:[LABStockVariable pricePrecision]];
    NSString *minStr = [LABStockFormatUtils getStringWithDouble:self.minValue andScale:[LABStockVariable pricePrecision]];
    //处理特殊情况,将数据放置在中间
    if ([maxStr isEqualToString:minStr]) {
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
    
    [self updateSelectIndex:index];
    return [self.timeLineView drawViewWithXPosition:xPosition drawModels:drawLineModels maxValue:max minValue:min accecssory:self.accessory];
}

- (void)updateSelectIndex:(NSInteger)index {
    ///更新背景上面的分割数值和指标数值
    [self.bgView updateSelectIndex:index maxValue:self.maxValue minValue:self.minValue accecssory:self.accessory];
}

@end
