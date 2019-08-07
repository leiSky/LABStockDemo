//
//  LABStockMACD.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockMACD.h"
#import "LABStockDataProtocol.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"
#import "UIColor+LABStock.h"
#import "LABStockFormatUtils.h"

@interface LABStockMACD ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockMACD

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"MACD";
        self.m_param = @[@(12), @(26), @(9)];
        self.paramName = @[@"DIF", @"DEA", @"MACD"];
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    for (int i=0; i<self.paramName.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [self.m_data addObject:array];
    }
    if (!self.m_data || self.m_data.count <= 0) {
        return;
    }
    for (NSNumber *num in self.m_param) {
        if ([num integerValue] > self.lineModels.count) {
            return;
        }
    }
    ///用0填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@(0)];
        }
    }
    NSMutableArray *dif = self.m_data[0];
    NSMutableArray *macd = self.m_data[1];
    NSMutableArray *dea = self.m_data[2];
    
    NSMutableArray *para = [NSMutableArray array];// 平滑系数
    NSMutableArray *sum = [NSMutableArray array];
    for (int j=0; j<3; j++) {
        [para addObject:@(0)];
        [sum addObject:@(0)];
    }
    NSMutableArray *n = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        n[i] = self.m_param[i];
        para[i] = [[NSNumber alloc] initWithDouble:2.0f / ([n[i] integerValue] + 1)];
        sum[i] = @(0);
    }
    
    CGFloat di = 0, a = 0, b = 0;
    for (int i=0; i<self.lineModels.count; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        di = [model.ms_close doubleValue];
        // 计算EMA12
        if (i < [n[0] intValue]) {
            sum[0] = [[NSNumber alloc] initWithDouble:([sum[0] doubleValue] + di)];
            a = (i == ([n[0] intValue] - 1)) ? ([sum[0] doubleValue] / [n[0] intValue]) : 0;
        }else {
            // sum[0] = sum[0] - self.lineModels[i-n[0]].ms_close.doubleValue + di;
            // a = sum[0] / n[0];
            a = (di - a) * [para[0] doubleValue] + a;
        }
        // 计算EMA26
        if (i < [n[1] intValue]) {
            sum[1] =[[NSNumber alloc] initWithDouble:([sum[1] doubleValue]+ di)];
            b = (i == ([n[1] intValue] - 1)) ? ([sum[1] doubleValue] / [n[1] intValue]) : 0;
        }else {
            // sum[1] = sum[1] - self.lineModels[i-n[1]].ms_close.doubleValue + di;
            // a = sum[1] / n[1];
            b = (di - b) * [para[1] doubleValue] + b;
        }
        dif[i] = [[NSNumber alloc] initWithDouble:(i >= [n[0] intValue] - 1 && i >= [n[1] intValue] ? a - b : 0)];
        // 计算MACD和柱差
        if (i < [n[1] intValue] + [n[2] intValue]) {
            sum[2] = [[NSNumber alloc] initWithDouble:([sum[2] doubleValue] + [dif[i] doubleValue])];
            macd[i] = [[NSNumber alloc] initWithDouble:(i == [n[1] intValue] + [n[2] intValue] - 1 ? ([sum[2] doubleValue]/[n[2] intValue]) : 0)];
        }else {
            macd[i] = [[NSNumber alloc] initWithDouble:((float)(([dif[i] doubleValue]-[macd[i-1] doubleValue])*0.2) + [macd[i-1] doubleValue])];
        }
        // dea[i] = 2 * (dif[i] - macd[i]);
        dea[i] = [[NSNumber alloc] initWithDouble:([dif[i] doubleValue] - [macd[i] doubleValue])];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[1] intValue]-1 range:range];
    [self getValueMaxMin:self.m_data[1] iFirst:[self.m_param[1] intValue]+[self.m_param[2] intValue]-2 range:range];
    [self getValueMaxMin:self.m_data[2] iFirst:[self.m_param[1] intValue]+[self.m_param[2] intValue]-2 range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0]
                   iFirst:[self.m_param[1] intValue]-1
                    color:[UIColor LABStock_accessoryFirstColor]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[1] intValue]+[self.m_param[2] intValue]-2
                    color:[UIColor LABStock_accessorySecondColor]];
    [self drawVertLine:ctx
                  rect:rect
             xPosition:xPosition
                   max:max
                   min:min
                  data:self.m_data[2]
                iFirst:[self.m_param[1] intValue]+[self.m_param[2] intValue]-2
         increaseColoe:[UIColor LABStock_accessoryIncreaseColor]
         decreaseColor:[UIColor LABStock_accessoryDecreaseColor]];
}

- (void)drawVertLine:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min data:(NSArray*)data iFirst:(NSInteger)iFirst increaseColoe:(UIColor *)increase decreaseColor:(UIColor *)decrease {
    if (!data || data.count == 0) {
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
    
    CGFloat zero = ABS(maxY - (0 - min)/unitValue);
    
    CGContextSetLineWidth(ctx, 1.0f);
    
    NSInteger j = self.range.location <= iFirst ? iFirst-self.range.location : 0;
    for (NSInteger i=begin; i<=end; i++, j++) {
        CGFloat x = xPosition + j*(lineGap + lineWidth);
        if ([data[i] doubleValue] > 0) {
            CGContextSetStrokeColorWithColor(ctx, increase.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(ctx, decrease.CGColor);
        }
        CGContextMoveToPoint(ctx, x, zero);
        CGContextAddLineToPoint(ctx, x, ABS(maxY - ([data[i] doubleValue] - min)/unitValue));
        CGContextStrokePath(ctx);
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableArray *textColor = [NSMutableArray array];
    [textColor addObject:[UIColor LABStock_textColor]];
    [textColor addObject:[UIColor LABStock_accessoryFirstColor]];
    [textColor addObject:[UIColor LABStock_accessorySecondColor]];
    [textColor addObject:[UIColor LABStock_accessoryThreeColor]];
    
    NSString *text = [self.accessoryName stringByAppendingString:@"("];
    for (int i=0; i <self.m_param.count; i++) {
        if (i>0) {
            text = [text stringByAppendingString:@","];
        }
        text = [text stringByAppendingString:[self.m_param[i] stringValue]];
    }
    text = [text stringByAppendingString:@")"];
    [textArray addObject:text];
    
    for (int i=0; i<self.paramName.count; i++) {
        if (!self.m_data[i]) {
            continue;
        }
        NSArray *dataArray = self.m_data[i];
        if (index>=dataArray.count) {
            continue;
        }
        NSString *param = self.paramName[i];
        double value = [dataArray[index] doubleValue];
        if (param) {
            NSString *newStr = [NSString stringWithFormat:@"%@:%@", param, [LABStockFormatUtils getStringWithDouble:value andScale:self.precision]];
            [textArray addObject:newStr];
        }
    }
    
    CGFloat gap = 3;
    CGFloat x = gap;
    NSMutableDictionary *attribute = [@{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont]} mutableCopy];
    for (int i=0; i<textArray.count; i++) {
        NSString *drawText = textArray[i];
        [attribute setObject:textColor[i] forKey:NSForegroundColorAttributeName];
        CGSize size = [LABStockVariable rectOfNSString:drawText attribute:attribute].size;
        [drawText drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width+gap;
    }
}

@end
