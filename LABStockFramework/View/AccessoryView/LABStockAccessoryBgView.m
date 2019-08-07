//
//  LABStockAccessoryBgView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryBgView.h"
#import "LABStockConstant.h"
#import "UIColor+LABStock.h"
#import "LABStockAccessoryBase.h"
#import "LABStockFormatUtils.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

@interface LABStockAccessoryBgLineView : UIView

@end

@implementation LABStockAccessoryBgLineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ///画背景线
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_bgLineColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGFloat centerLineY = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap)/2.0 + LABStockScrollViewTopGap;
    ///横线
    const CGPoint line1[] = {CGPointMake(0, 0),CGPointMake(CGRectGetWidth(self.frame), 0)};
    const CGPoint line2[] = {CGPointMake(0, centerLineY),CGPointMake(CGRectGetWidth(self.frame), centerLineY)};
    const CGPoint line3[] = {CGPointMake(0, CGRectGetHeight(self.frame)),CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line1, 2);
    CGContextStrokeLineSegments(ctx, line2, 2);
    CGContextStrokeLineSegments(ctx, line3, 2);
    ///竖线
    CGFloat unitWidth = CGRectGetWidth(self.frame)/4.0;
    const CGPoint line4[] = {CGPointMake(0, 0), CGPointMake(0, CGRectGetHeight(self.frame))};
    const CGPoint line5[] = {CGPointMake(unitWidth, 0), CGPointMake(unitWidth, CGRectGetHeight(self.frame))};
    const CGPoint line6[] = {CGPointMake(unitWidth*2, 0), CGPointMake(unitWidth*2, CGRectGetHeight(self.frame))};
    const CGPoint line7[] = {CGPointMake(unitWidth*3, 0), CGPointMake(unitWidth*3, CGRectGetHeight(self.frame))};
    const CGPoint line8[] = {CGPointMake(CGRectGetWidth(self.frame), 0), CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line4, 2);
    CGContextStrokeLineSegments(ctx, line5, 2);
    CGContextStrokeLineSegments(ctx, line6, 2);
    CGContextStrokeLineSegments(ctx, line7, 2);
    CGContextStrokeLineSegments(ctx, line8, 2);
}

@end

@interface LABStockAccessoryBgDataView : UIView

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat min;
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

- (void)updateSelectIndex:(CGFloat)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory;

@end

@implementation LABStockAccessoryBgDataView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ///绘制坐标值
    CGFloat centerLineY = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap)/2.0 + LABStockScrollViewTopGap;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:[UIColor LABStock_textColor]};
    
    NSMutableArray *textPointArray = [NSMutableArray array];
    CGPoint p1 = CGPointMake(CGRectGetWidth(self.frame), 0);
    CGPoint p2 = CGPointMake(CGRectGetWidth(self.frame), centerLineY);
    CGPoint p3 = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [textPointArray addObjectsFromArray:@[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2],
                                          [NSValue valueWithCGPoint:p3]]];
    
    CGFloat average = (self.max+self.min)/2.0;
    NSMutableArray *textArray = [NSMutableArray array];
    NSString *text1 = [LABStockFormatUtils getStringWithDouble:self.max andScale:self.accessory.precision];
    NSString *text2 = [LABStockFormatUtils getStringWithDouble:average andScale:self.accessory.precision];
    NSString *text3 = [LABStockFormatUtils getStringWithDouble:self.min andScale:self.accessory.precision];
    [textArray addObjectsFromArray:@[text1, text2, text3]];
    
    CGFloat rightGap = 3;
    [textPointArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        CGPoint point = [obj CGPointValue];
        NSString *text = textArray[idx];
        CGSize size = [LABStockVariable rectOfNSString:text attribute:attribute].size;
        CGPoint drawPoint;
        if (idx == 0) {//第一个在线的下面
            drawPoint = CGPointMake(point.x-size.width-rightGap, point.y);
        }else {
            drawPoint = CGPointMake(point.x-size.width-rightGap, point.y-size.height);
        }
        [text drawAtPoint:drawPoint withAttributes:attribute];
    }];
    if (self.accessory) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.accessory drawGraphWithCtx:ctx rect:rect selectIndex:self.selectIndex];
    }
}

- (void)updateSelectIndex:(CGFloat)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory {
    self.selectIndex = index;
    self.max = maxValue;
    self.min = minValue;
    self.accessory = accessory;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end

@interface LABStockAccessoryBgView ()

@property (nonatomic, strong) LABStockAccessoryBgLineView *bgLineView;
@property (nonatomic, strong) LABStockAccessoryBgDataView *bgDataView;

@end

@implementation LABStockAccessoryBgView

#pragma mark --初始化

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

#pragma mark --懒加载,getter

- (LABStockAccessoryBgLineView *)bgLineView {
    if (!_bgLineView) {
        _bgLineView = [LABStockAccessoryBgLineView new];
        _bgLineView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgLineView;
}

- (LABStockAccessoryBgDataView *)bgDataView {
    if (!_bgDataView) {
        _bgDataView = [LABStockAccessoryBgDataView new];
        _bgDataView.backgroundColor = [UIColor clearColor];
    }
    return _bgDataView;
}

#pragma mark --外部方法

- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory {
    ///背景网格不会变动,所以只更新背景数据就行了
    [self.bgDataView updateSelectIndex:index maxValue:maxValue minValue:minValue accecssory:accessory];
}

@end
