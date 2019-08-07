//
//  LABStockTimeLineBgView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeLineBgView.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"
#import "LABStockDataProtocol.h"
#import "LABStockAccessoryBase.h"
#import "LABStockFormatUtils.h"
#import <Masonry/Masonry.h>

///背景网格View
@interface LABStockTimeLineBgLineView : UIView

@end

@implementation LABStockTimeLineBgLineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_bgLineColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGFloat unitHeight = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2)/4.0;
    CGFloat centerLineY = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap)/2.0 + LABStockScrollViewTopGap;
    ///横线
    const CGPoint line1[] = {CGPointMake(0, 0),CGPointMake(CGRectGetWidth(self.frame), 0)};
    const CGPoint line2[] = {CGPointMake(0, centerLineY-unitHeight),CGPointMake(CGRectGetWidth(self.frame), centerLineY-unitHeight)};
    const CGPoint line3[] = {CGPointMake(0, centerLineY),CGPointMake(CGRectGetWidth(self.frame), centerLineY)};
    const CGPoint line4[] = {CGPointMake(0, centerLineY+unitHeight),CGPointMake(CGRectGetWidth(self.frame), centerLineY+unitHeight)};
    const CGPoint line5[] = {CGPointMake(0, CGRectGetHeight(self.frame)),CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line1, 2);
    CGContextStrokeLineSegments(ctx, line2, 2);
    CGContextStrokeLineSegments(ctx, line3, 2);
    CGContextStrokeLineSegments(ctx, line4, 2);
    CGContextStrokeLineSegments(ctx, line5, 2);
    ///竖线
    CGFloat unitWidth = CGRectGetWidth(self.frame)/4.0;
    const CGPoint line6[] = {CGPointMake(0, 0), CGPointMake(0, CGRectGetHeight(self.frame))};
    const CGPoint line7[] = {CGPointMake(unitWidth, 0), CGPointMake(unitWidth, CGRectGetHeight(self.frame))};
    const CGPoint line8[] = {CGPointMake(unitWidth*2, 0), CGPointMake(unitWidth*2, CGRectGetHeight(self.frame))};
    const CGPoint line9[] = {CGPointMake(unitWidth*3, 0), CGPointMake(unitWidth*3, CGRectGetHeight(self.frame))};
    const CGPoint line10[] = {CGPointMake(CGRectGetWidth(self.frame), 0), CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line6, 2);
    CGContextStrokeLineSegments(ctx, line7, 2);
    CGContextStrokeLineSegments(ctx, line8, 2);
    CGContextStrokeLineSegments(ctx, line9, 2);
    CGContextStrokeLineSegments(ctx, line10, 2);
}

@end

///背景数据View
@interface LABStockTimeLineBgDataView : UIView

///选中的索引,用于传值给指标,更新指标数据
@property (nonatomic, assign) NSInteger selectIndex;
///最大数据的范围
@property (nonatomic, assign) CGFloat max;
///最小数据的范围
@property (nonatomic, assign) CGFloat min;
//指标对象
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

///更新网格数据和指标数据
///@param index 选中的索引,用于传值给指标,更新指标数据
///@param maxValue 最大数据范围
///@param minValue 最小数据范围
///@param accessory 指标对象
- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory;

@end

@implementation LABStockTimeLineBgDataView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    ///绘制坐标值
    CGFloat unitHeight = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap-LABStockLineMainViewMinY*2)/4.0;
    CGFloat centerLineY = (CGRectGetHeight(self.frame)-LABStockScrollViewTopGap)/2.0 + LABStockScrollViewTopGap;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont], NSForegroundColorAttributeName:[UIColor LABStock_textColor]};
    
    NSMutableArray *textPointArray = [NSMutableArray array];
    CGPoint p1 = CGPointMake(CGRectGetWidth(self.frame), 0);
    CGPoint p2 = CGPointMake(CGRectGetWidth(self.frame), centerLineY-unitHeight);
    CGPoint p3 = CGPointMake(CGRectGetWidth(self.frame), centerLineY);
    CGPoint p4 = CGPointMake(CGRectGetWidth(self.frame), centerLineY+unitHeight);
    CGPoint p5 = CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [textPointArray addObjectsFromArray:@[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2],
                                          [NSValue valueWithCGPoint:p3], [NSValue valueWithCGPoint:p4],
                                          [NSValue valueWithCGPoint:p5]]];
    
    CGFloat unitPrice = (self.max-self.min)/4.0;
    CGFloat average = (self.max+self.min)/2.0;
    NSMutableArray *textArray = [NSMutableArray array];
    int pricePrecision = [LABStockVariable pricePrecision];
    NSString *text1 = [LABStockFormatUtils getStringWithDouble:self.max andScale:pricePrecision];
    NSString *text2 = [LABStockFormatUtils getStringWithDouble:average+unitPrice andScale:pricePrecision];
    NSString *text3 = [LABStockFormatUtils getStringWithDouble:average andScale:pricePrecision];
    NSString *text4 = [LABStockFormatUtils getStringWithDouble:average-unitPrice andScale:pricePrecision];
    NSString *text5 = [LABStockFormatUtils getStringWithDouble:self.min andScale:pricePrecision];
    [textArray addObjectsFromArray:@[text1, text2, text3, text4, text5]];
    
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
    //绘制模型数据
    if (self.accessory) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.accessory drawGraphWithCtx:ctx rect:rect selectIndex:self.selectIndex];
    }
}

- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory {
    self.selectIndex = index;
    self.max = maxValue;
    self.min = minValue;
    self.accessory = accessory;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end

@interface LABStockTimeLineBgView ()

@property (nonatomic, strong) LABStockTimeLineBgLineView *bgLineView;
@property (nonatomic, strong) LABStockTimeLineBgDataView *bgDataView;

@end

@implementation LABStockTimeLineBgView

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

- (void)updateSelectIndex:(NSInteger)index maxValue:(CGFloat)maxValue minValue:(CGFloat)minValue accecssory:(LABStockAccessoryBase *)accessory {
    ///背景网格不会变动,所以只更新背景数据就行了
    [self.bgDataView updateSelectIndex:index maxValue:maxValue minValue:minValue accecssory:accessory];
}

#pragma mark --懒加载,getter

- (LABStockTimeLineBgLineView *)bgLineView {
    if (!_bgLineView) {
        _bgLineView = [LABStockTimeLineBgLineView new];
        _bgLineView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgLineView;
}

- (LABStockTimeLineBgDataView *)bgDataView {
    if (!_bgDataView) {
        _bgDataView = [LABStockTimeLineBgDataView new];
        _bgDataView.backgroundColor = [UIColor clearColor];
    }
    return _bgDataView;
}

@end
