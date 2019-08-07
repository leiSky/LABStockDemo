//
//  LABStockVolumeContainerView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVolumeContainerView.h"
#import "LABStockVolumeBgView.h"
#import "LABStockVolumeView.h"
#import "LABStockVolumeMA.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import <Masonry/Masonry.h>

@interface LABStockVolumeContainerView ()

///网格背景
@property (nonatomic, strong) LABStockVolumeBgView *bgView;
///成交量绘图页面
@property (nonatomic, strong) LABStockVolumeView *volumeView;

///数据范围,最大值,最小值为0
@property (nonatomic, assign) CGFloat maxValue;

///ma指标
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

@end

@implementation LABStockVolumeContainerView

#pragma mark --初始化

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
    [self addSubview:self.volumeView];
    [self.volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(self).offset(LABStockScrollViewTopGap);
    }];
}

#pragma mark--懒加载

- (LABStockVolumeBgView *)bgView {
    if (!_bgView) {
        _bgView = [LABStockVolumeBgView new];
        _bgView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgView;
}

- (LABStockVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [LABStockVolumeView new];
        _volumeView.backgroundColor = [UIColor clearColor];
    }
    return _volumeView;
}

#pragma mark --外部方法

- (void)drawViewWithXPosition:(CGFloat)xPosition
                   lineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                    drawRange:(NSRange)range
                  selectIndex:(NSInteger)index {
    //计算最大值
    CGFloat max =  [[[drawLineModels valueForKeyPath:@"ms_volume"] valueForKeyPath:@"@max.doubleValue"] doubleValue];
    LABStockVolumeMA *ma = [[LABStockVolumeMA alloc] initWithLineModels:lineModels MATypes:@[@(LABStockMAType5),@(LABStockMAType10)]];
    ma.range = range;
    [ma getMaxMin:range];
    self.accessory = ma;
    
    self.maxValue = MAX(ma.maxValue, max);
    
    id<LABStockDataProtocol> preModel = nil;
    if (range.location != 0) {//说明不是从0开始
        preModel = lineModels[range.location-1];
    }
    
    [self updateSelectIndex:index];
    [self.volumeView drawViewWithXPosition:xPosition drawModelsPreModel:preModel drawModels:drawLineModels maxValue:self.maxValue accecssory:self.accessory];
}

- (void)updateSelectIndex:(NSInteger)index {
    [self.bgView updateSelectIndex:index maxValue:self.maxValue accecssory:self.accessory];
}

@end
