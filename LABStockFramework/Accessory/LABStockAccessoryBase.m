//
//  LABStockAccessoryBase.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryBase.h"
#import "LABStockDataProtocol.h"
#import "LABStockDrawLine.h"
#import "LABStockVariable.h"

@implementation LABStockAccessoryBase

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super init]) {
        self.lineModels = lineModels;
        self.accessoryName = @"baseAccessory";
        self.maxValue = -1*MAXFLOAT;
        self.minValue = MAXFLOAT;
        self.precision = 2;
        self.m_data = [NSMutableArray array];
    }
    return self;
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {}

- (void)getMaxMin:(NSRange)range {}

- (void)getValueMaxMin:(NSArray<NSNumber *> *)data iFirst:(NSInteger)iFirst range:(NSRange)range {
    if (!data || data.count == 0) {
        return;
    }
    if (iFirst > self.lineModels.count) {
        return;
    }
    NSInteger begin, end;
    begin = range.location <= iFirst ? iFirst : range.location;
    end = range.location + range.length-1;
    for (NSInteger i = begin; i <= end; i++) {
        if ([data[i] doubleValue] > self.maxValue) {
            self.maxValue = [data[i] doubleValue];
        }
        if ([data[i] doubleValue] < self.minValue) {
            self.minValue = [data[i] doubleValue];
        }
    }
}

- (void)averageClose:(NSInteger)dayCount dataArray:(NSMutableArray<NSNumber *> *)dataArray {
    if (dayCount > self.lineModels.count || dayCount < 1) {
        return;
    }
    
    NSInteger i;
    CGFloat preClose = 0;
    CGFloat sum = 0.0;
    for (i=0; i<dayCount-1; i++) {
        sum += self.lineModels[i].ms_close.doubleValue;
    }
    for (i=dayCount-1; i<self.lineModels.count; i++) {
        sum -= preClose;
        sum += self.lineModels[i].ms_close.doubleValue;
        dataArray[i] = [NSNumber numberWithDouble:(CGFloat)sum/dayCount];
        preClose = self.lineModels[i-dayCount+1].ms_close.doubleValue;
    }
}

- (void)averageData:(NSInteger)begin
              count:(NSInteger)count
           dayCount:(NSInteger)dayCount
             source:(NSArray<NSNumber *> *)source
        destination:(NSMutableArray<NSNumber *> *)destination {
    if (!source || !destination) {
        return;
    }
    if (dayCount>count-begin || dayCount<1) {
        return;
    }
    
    CGFloat preValue = 0;
    CGFloat sum = 0;
    for (NSInteger i=count-1; i>count-dayCount; i--) {
        sum += [source[i] doubleValue];
    }
    for (NSInteger i=count-1; i>=begin+dayCount-1; i--) {
        sum -= preValue;
        sum += [source[i-dayCount+1] doubleValue];
        preValue = [source[i] doubleValue];
        destination[i] = [[NSNumber alloc] initWithDouble:(CGFloat) (sum / dayCount)];
    }
}

- (void)drawLineWithCtx:(CGContextRef)ctx
                   rect:(CGRect)rect
              xPosition:(CGFloat)xPosition
                    max:(CGFloat)max
                    min:(CGFloat)min
                   data:(NSArray<NSNumber *> *)data
                 iFirst:(NSInteger)iFirst
                  color:(UIColor *)color {
    if (!data || data.count <= 1) {
        return;
    }
    if (iFirst > self.lineModels.count) {
        return;
    }
    CGFloat minY = self.minY;
    CGFloat maxY = self.maxY;
    CGFloat unitValue = (max - min)/(maxY - minY);
    if (unitValue == 0) {
        unitValue = 0.01f;
    }
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    
    NSInteger begin = self.range.location <= iFirst ? iFirst : self.range.location;
    NSInteger end = self.range.location + self.range.length-1;
    
    NSMutableArray *position = [NSMutableArray array];
    if (begin > iFirst) {
        ///开始画线第一条在画线在屏幕外了,此时第一个点从屏幕最左边开始
        CGFloat x = xPosition - (lineGap + lineWidth);
        CGFloat value = [data[begin-1] doubleValue];
        [position addObject:[NSValue valueWithCGPoint:CGPointMake(x, (maxY - (value - min)/unitValue))]];
    }
    ///计算绘制数据对应指标有效数据的x坐标
    NSInteger j = self.range.location <= iFirst ? iFirst-self.range.location : 0;
    for (NSInteger i=begin; i<=end; i++, j++) {
        CGFloat x = xPosition + j*(lineGap + lineWidth);
        CGFloat value = [data[i] doubleValue];
        [position addObject:[NSValue valueWithCGPoint:CGPointMake(x, (maxY - (value - min)/unitValue))]];
    }
    ///看最后一条数据后面还有没有数据,有就加一个最右边的点
    id<LABStockDataProtocol> model = self.lineModels[end];
    if (end >= begin && model.nextModel) {
        CGFloat x = xPosition + j*(lineGap + lineWidth);
        CGFloat value = [data[end+1] doubleValue];
        [position addObject:[NSValue valueWithCGPoint:CGPointMake(x, (maxY - (value - min)/unitValue))]];
    }
    LABStockDrawLine *line = [[LABStockDrawLine alloc] initWithContext:ctx];
    [line drawWithColor:color positions:position];
}

@end
