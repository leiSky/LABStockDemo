//
//  LABStockSAR.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockSAR.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockSAR ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@property (nonatomic, strong) NSNumber *SAR_UP;
@property (nonatomic, strong) NSNumber *SAR_DOWN;
@property (nonatomic, strong) NSNumber *SAR_CUP;
@property (nonatomic, strong) NSNumber *SAR_CDOWN;

@end

@implementation LABStockSAR

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"SAR";
        self.m_param = @[@(5)];
        self.paramName = @[@""];
        self.SAR_UP = [[NSNumber alloc] initWithInt:0x00];
        self.SAR_DOWN =[[NSNumber alloc] initWithInt:0x01];
        self.SAR_CUP = [[NSNumber alloc] initWithInt:0x10];
        self.SAR_CDOWN =[[NSNumber alloc] initWithInt:0x11];
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    for (int i=0; i<2; i++) {
        [self.m_data addObject:[NSMutableArray array]];
    }
    if (!self.m_data || self.m_data.count <= 0) {
        return;
    }
    int n = [self.m_param[0] intValue];
    if (n > self.lineModels.count || n < 3) {
        return;
    }
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    NSMutableArray* sar = self.m_data[0];
    NSMutableArray* sign = self.m_data[1];
    CGFloat xs;
    
    // 计算第一天的SAR
    xs = 0.02f;
    if (self.lineModels[n-1].ms_close.doubleValue < self.lineModels[n-2].ms_close.doubleValue) {
        if (self.lineModels[n-2].ms_close.doubleValue <= self.lineModels[n-3].ms_close.doubleValue) {
            sign[n - 1] = self.SAR_DOWN;
        }else {
            sign[n - 1] = self.SAR_CDOWN;
        }
    }else if (self.lineModels[n-1].ms_close.doubleValue > self.lineModels[n-2].ms_close.doubleValue) {
        if (self.lineModels[n-2].ms_close.doubleValue >= self.lineModels[n-3].ms_close.doubleValue) {
            sign[n - 1] = self.SAR_UP;
        }else {
            sign[n - 1] = self.SAR_CUP;
        }
    }else {
        if (self.lineModels[n-2].ms_close.doubleValue < self.lineModels[n-3].ms_close.doubleValue) {
            sign[n - 1] = self.SAR_DOWN;
        }else if (self.lineModels[n-2].ms_close.doubleValue > self.lineModels[n-3].ms_close.doubleValue) {
            sign[n - 1] = self.SAR_UP;
        }else {
            sign[n - 1] = self.SAR_CUP;
        }
    }
    
    if (sign[n - 1] == self.SAR_DOWN || sign[n - 1] == self.SAR_CDOWN) { // 空头
        sar[n - 1] = [[NSNumber alloc] initWithDouble:-1.0E36f];
        for (int j = n - 1; j >= 0; j--) {
            sar[n - 1] = [[NSNumber alloc] initWithDouble:fmax([sar[n - 1] doubleValue], self.lineModels[j].ms_high.doubleValue)];
        }
    }else { // 多头
        sar[n - 1] = [[NSNumber alloc] initWithDouble:1.0E36f];
        for (int j = n - 1; j >= 0; j--) {
            sar[n - 1] = [[NSNumber alloc] initWithDouble:fmin([sar[n - 1] doubleValue], self.lineModels[j].ms_low.doubleValue)];
        }
    }
    // 计算以后的SAR
    for (int i = n; i < [self.lineModels count]; i++) {
        if (sign[i - 1] == self.SAR_UP || sign[i - 1] == self.SAR_CUP) { // 多头
            if (self.lineModels[i].ms_close.doubleValue < [sar[i - 1] doubleValue]) { // 变向转空头
                sar[i] = [[NSNumber alloc] initWithDouble:-1.0E36f];
                for (int j = i; j > i - n; j--) {
                    sar[i] = [[NSNumber alloc] initWithDouble:fmax([sar[i] doubleValue], self.lineModels[j].ms_high.doubleValue)];
                }
                sign[i] = self.SAR_CDOWN;
                xs = 0.02f;
            }else {
                sar[i] =[[NSNumber alloc] initWithDouble:([sar[i - 1] doubleValue] + xs * (self.lineModels[i-1].ms_high.doubleValue - [sar[i - 1] doubleValue]))] ;
                xs = xs < 0.2f ? xs + 0.02f : xs;
                sign[i] = self.SAR_UP;
            }
        }else { // 空头
            if (self.lineModels[i].ms_close.doubleValue > [sar[i - 1] doubleValue]) { // 变向转多头
                sar[i] = [[NSNumber alloc] initWithDouble:1.0E36f];
                for (int j = i; j > i - n; j--) {
                    sar[i] = [[NSNumber alloc] initWithDouble:fmin([sar[i] doubleValue], self.lineModels[j].ms_low.doubleValue)];
                }
                sign[i] = self.SAR_CUP;
                xs = 0.02f;
            }else {
                sar[i] = [[NSNumber alloc] initWithDouble:([sar[i - 1] doubleValue] + xs * (self.lineModels[i-1].ms_low.doubleValue - [sar[i - 1] doubleValue]))];
                xs = xs < 0.2f ? xs + 0.02f : xs;
                sign[i] = self.SAR_DOWN;
            }
        }
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    [super getMaxMin:range];
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] integerValue] range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    self.minY = 5;
    self.maxY = CGRectGetHeight(rect)-5;
    [super drawGraphWithCtx:ctx rect:rect xPosition:xPosition max:max min:min];
    NSMutableArray *data = self.m_data[0];
    NSMutableArray *sign = self.m_data[1];
    NSInteger iBegin = [self.m_param[0] integerValue] - 1;
    if (!data || !sign) {
        return;
    }
    
    if (max - min == 0 || rect.size.height <= 0) {return;}
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    
    CGFloat minY = self.minY;
    CGFloat maxY = self.maxY;
    CGFloat unitValue = (max - min)/(maxY - minY);
    if (unitValue == 0) {
        unitValue = 0.01f;
    }
    
    NSInteger begin = self.range.location <= iBegin ? iBegin : self.range.location;
    NSInteger end = self.range.location + self.range.length-1;
    NSInteger j = self.range.location <= iBegin ? iBegin-self.range.location : 0;
    for (NSInteger i=begin; i<=end; i++, j++) {
        CGContextBeginPath(ctx);
        CGFloat x = xPosition + j*(lineGap + lineWidth);
        CGFloat value = [data[i] doubleValue];
        CGFloat y = ABS(maxY - (value - min)/unitValue);
        CGFloat radius = lineWidth/2.0;
        if (radius > 5) {
            radius = 5;
        }
        CGContextAddArc(ctx, x, y, radius, 0, 2*M_PI, 0);
        CGContextClosePath(ctx);
        if (sign[i] == self.SAR_DOWN) {
            CGContextSetFillColorWithColor(ctx, [UIColor LABStock_accessoryDecreaseColor].CGColor);
            CGContextFillPath(ctx);
        }else if (sign[i] == self.SAR_UP) {
            CGContextSetFillColorWithColor(ctx, [UIColor LABStock_accessoryIncreaseColor].CGColor);
            CGContextFillPath(ctx);
        } else {
            CGContextSetFillColorWithColor(ctx, [UIColor LABStock_accessoryEqualColor].CGColor);
            CGContextFillPath(ctx);
        }
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor]];
    
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
        if (param && param.length > 0) {
            NSString *newStr = [NSString stringWithFormat:@"%@:%@", param, [LABStockFormatUtils getStringWithDouble:value andScale:self.precision]];
            [textArray addObject:newStr];
        }else {
            NSString *newStr = [NSString stringWithFormat:@"%@", [LABStockFormatUtils getStringWithDouble:value andScale:self.precision]];
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
