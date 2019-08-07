//
//  LABStockMIKE.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockMIKE.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockMIKE ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockMIKE

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"MIKE";
        self.m_param = @[@(12)];
        self.paramName = @[@"WR", @"MR", @"SR", @"WS", @"MS", @"SS"];
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    for (int i=0; i<self.paramName.count; i++) {
        [self.m_data addObject:[NSMutableArray array]];
    }
    if (!self.m_data || self.m_data.count <= 0) {
        return;
    }
    int n = [self.m_param[0] intValue];
    if (n > self.lineModels.count) {
        return;
    }
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    CGFloat TYP, high, low, close;
    [self getN_DayLow:n data:self.m_data[0]];
    [self getN_DayHigh:n data:self.m_data[1]];
    
    for (int i=n-1; i<self.lineModels.count; i++) {
        close = self.lineModels[i].ms_close.doubleValue;
        low = [self.m_data[0][i] doubleValue];
        high = [self.m_data[1][i] doubleValue];
        
        // 设定一个初始价格(英文全称为Typicalprice,简称TYP),
        // 计算公式：TYP＝(最高价＋最低价＋收盘价)/3
        TYP = (close + high + low) / 3;
        
        // MIKE指标有三条初级、中级、强力压力,分别为WR Weak-R,初级压力 、
        // MR Medium-R,中级压力 、SR Strong-R,强力压力
        // 计算公式分别如下:
        self.m_data[0][i] = [[NSNumber alloc] initWithDouble:(TYP + (TYP - low))];   //  WR＝TYP＋TYP-(N天最低价)
        self.m_data[1][i] = [[NSNumber alloc] initWithDouble:(TYP + (high - low))];  //  MR＝TYP＋(N天最高价-N天最低价)
        self.m_data[2][i] = [[NSNumber alloc] initWithDouble:(2 * high - low)];      //  SR＝2×N天最高价-N天最低价
        
        // MIKE指标有三条初级、中级、强力支撑,分别为WS Weak-S,初级支撑 、
        // MS Medium-S,中级支撑 、SS Strong-S,强力支撑 。
        // 计算公式如下:
        self.m_data[3][i] = [[NSNumber alloc] initWithDouble:(TYP - (high - TYP))];  //  WS＝TYP-(N天最高价-TYP)
        self.m_data[4][i] = [[NSNumber alloc] initWithDouble:(TYP - (high - low))];  //  MS＝TYP-(N天最高价-N天最低价)
        self.m_data[5][i] = [[NSNumber alloc] initWithDouble:(2 * low - high)];      //  SS＝2×N天最低价-N天最高价
    }
}

- (void)getN_DayLow:(NSInteger)day data:(NSMutableArray *)data {
    if (!self.lineModels || self.lineModels.count == 0) {
        return;
    }
    if (day > self.lineModels.count) {
        return;
    }
    CGFloat temp = 0.0f;
    for (NSInteger i=day-1; i<self.lineModels.count; i++) {
        temp = self.lineModels[i-day+1].ms_low.doubleValue;
        for (NSInteger j=i-day+2; j<=i; j++) {
            if (temp > self.lineModels[j].ms_low.doubleValue) {
                temp = self.lineModels[j].ms_low.doubleValue;
            }
        }
        data[i] = [[NSNumber alloc] initWithDouble:(temp)];
    }
}

- (void)getN_DayHigh:(NSInteger)day data:(NSMutableArray *)data {
    if (!self.lineModels || self.lineModels.count == 0) {
        return;
    }
    if (day > self.lineModels.count) {
        return;
    }
    CGFloat temp = 0.0f;
    for (NSInteger i=day-1; i<self.lineModels.count; i++) {
        temp = self.lineModels[i-day+1].ms_high.doubleValue;
        for (NSInteger j=i-day+2; j<=i; j++) {
            if (temp < self.lineModels[j].ms_low.doubleValue) {
                temp = self.lineModels[j].ms_low.doubleValue;
            }
        }
        data[i] = [[NSNumber alloc] initWithDouble:(temp)];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    [super getMaxMin:range];
    for (int i=0; i<self.paramName.count; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[0] intValue]-1 range:range];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawUSAGraphWithCtx:ctx rect:rect xPosition:xPosition max:max min:min];
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor],
                       [UIColor LABStock_accessoryThreeColor],
                       [UIColor LABStock_accessoryFourColor],
                       [UIColor LABStock_accessoryFiveColor],
                       [UIColor LABStock_accessorySixColor]];
    for (int i=0; i<self.m_data.count; i++) {
        [self drawLineWithCtx:ctx
                         rect:rect
                    xPosition:xPosition
                          max:max
                          min:min
                         data:self.m_data[i]
                       iFirst:[self.m_param[0] intValue]-1
                        color:color[i]];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor],
                           [UIColor LABStock_accessorySecondColor],
                           [UIColor LABStock_accessoryThreeColor],
                           [UIColor LABStock_accessoryFourColor],
                           [UIColor LABStock_accessoryFiveColor],
                           [UIColor LABStock_accessorySixColor]];
    
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
    NSMutableDictionary *attribute = [@{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont-1]} mutableCopy];
    for (int i=0; i<textArray.count; i++) {
        NSString *drawText = textArray[i];
        [attribute setObject:textColor[i] forKey:NSForegroundColorAttributeName];
        CGSize size = [LABStockVariable rectOfNSString:drawText attribute:attribute].size;
        [drawText drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width+gap;
    }
}

@end
