//
//  LABStockVolumeBgView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVolumeBgView.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"
#import "LABStockAccessoryBase.h"
#import <Masonry/Masonry.h>

///背景网格View
@interface LABStockVolumeBgLineView : UIView

@end

@implementation LABStockVolumeBgLineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ///画背景线
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_bgLineColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    ///横线
    const CGPoint line1[] = {CGPointMake(0, 0),CGPointMake(CGRectGetWidth(self.frame), 0)};
    const CGPoint line2[] = {CGPointMake(0, CGRectGetHeight(self.frame)),CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line1, 2);
    CGContextStrokeLineSegments(ctx, line2, 2);
    ///竖线
    CGFloat unitWidth = CGRectGetWidth(self.frame)/4.0;
    const CGPoint line3[] = {CGPointMake(0, 0), CGPointMake(0, CGRectGetHeight(self.frame))};
    const CGPoint line4[] = {CGPointMake(unitWidth, 0), CGPointMake(unitWidth, CGRectGetHeight(self.frame))};
    const CGPoint line5[] = {CGPointMake(unitWidth*2, 0), CGPointMake(unitWidth*2, CGRectGetHeight(self.frame))};
    const CGPoint line6[] = {CGPointMake(unitWidth*3, 0), CGPointMake(unitWidth*3, CGRectGetHeight(self.frame))};
    const CGPoint line7[] = {CGPointMake(CGRectGetWidth(self.frame), 0), CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line3, 2);
    CGContextStrokeLineSegments(ctx, line4, 2);
    CGContextStrokeLineSegments(ctx, line5, 2);
    CGContextStrokeLineSegments(ctx, line6, 2);
    CGContextStrokeLineSegments(ctx, line7, 2);
}

@end

///背景数据View
@interface LABStockVolumeBgDataView : UIView

///选中的索引,用于传值给指标,更新指标数据
@property (nonatomic, assign) NSInteger selectIndex;
///最大数据的范围
@property (nonatomic, assign) CGFloat max;
//指标对象
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

///更新网格数据和指标数据
///@param index 选中的索引,用于传值给指标,更新指标数据
///@param maxValue 最大数据范围
///@param accessory 指标对象
- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue accecssory:(LABStockAccessoryBase *)accessory;

@end

@implementation LABStockVolumeBgDataView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ///绘制坐标值
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:[UIColor LABStock_textColor]};
    int volumePrecision = [LABStockVariable volumePrecision];
    CGFloat rightGap = 3;
    CGPoint p = CGPointMake(CGRectGetWidth(self.frame), 0);
    NSString *text = [LABStockFormatUtils getStringWithDouble:self.max andScale:volumePrecision];
    CGSize size = [LABStockVariable rectOfNSString:text attribute:attribute].size;
    [text drawAtPoint:CGPointMake(p.x-rightGap-size.width, p.y) withAttributes:attribute];
    if (self.accessory) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.accessory drawGraphWithCtx:ctx rect:rect selectIndex:self.selectIndex];
    }
}

- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue accecssory:(LABStockAccessoryBase *)accessory {
    self.selectIndex = index;
    self.max = maxValue;
    self.accessory = accessory;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end

@interface LABStockVolumeBgView ()

@property (nonatomic, strong) LABStockVolumeBgLineView *bgLineView;
@property (nonatomic, strong) LABStockVolumeBgDataView *bgDataView;

@end

@implementation LABStockVolumeBgView

#pragma mark --初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bgLineView];
    [self.bgLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.bgDataView];
    [self.bgDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark --外部方法

- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue accecssory:(LABStockAccessoryBase *)accessory {
    ///背景网格不会变动,所以只更新背景数据就行了
    [self.bgDataView updateSelectIndex:index maxValue:maxValue accecssory:accessory];
}

#pragma mark --懒加载,getter

- (LABStockVolumeBgLineView *)bgLineView {
    if (!_bgLineView) {
        _bgLineView = [LABStockVolumeBgLineView new];
        _bgLineView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgLineView;
}

- (LABStockVolumeBgDataView *)bgDataView {
    if (!_bgDataView) {
        _bgDataView = [LABStockVolumeBgDataView new];
        _bgDataView.backgroundColor = [UIColor clearColor];
    }
    return _bgDataView;
}

@end
