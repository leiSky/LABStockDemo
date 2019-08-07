//
//  LABStockRSI.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockRSI.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockRSI()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockRSI

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"RSI";
        self.m_param = @[@(6), @(12), @(24)];
        self.paramName = @[@"RSI1", @"RSI2", @"RSI3"];
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
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
        [self getRSI:[self.m_param[i] intValue] rsi:self.m_data[i]];
    }
}

- (void)getRSI:(NSInteger)n rsi:(NSMutableArray *)rsi {
    if (n>self.lineModels.count) {
        [rsi removeAllObjects];
        return;
    }
    CGFloat up = 0, down = 0;
    CGFloat preup, predown;
    for (int i=1; i<n; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        if (model.ms_close.doubleValue > preModel.ms_close.doubleValue) {
            up += model.ms_close.doubleValue - preModel.ms_close.doubleValue;
        }else {
            down += preModel.ms_close.doubleValue - model.ms_close.doubleValue;
        }
    }
    if (up + down == 0) {
        rsi[n-1] = [[NSNumber alloc] initWithDouble:50];
    }else {
        rsi[n-1] = [[NSNumber alloc] initWithDouble:(up / (up + down) * 100)];
    }
    preup = predown = 0;
    for (NSInteger i=n; i<self.lineModels.count; i++) {
        up -= preup;
        down -= predown;
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        if (model.ms_close.doubleValue > preModel.ms_close.doubleValue) {
            up += model.ms_close.doubleValue - preModel.ms_close.doubleValue;
        }else {
            down += preModel.ms_close.doubleValue - model.ms_close.doubleValue;
        }
        if (up + down == 0) {
            rsi[i] = rsi[i-1];
        }else {
            rsi[i] = [[NSNumber alloc] initWithDouble:(up / (up + down) * 100)];
        }
        
        preup = predown = 0;
        model = self.lineModels[i-n+1];
        preModel = self.lineModels[i-n];
        if (model.ms_close.doubleValue > preModel.ms_close.doubleValue) {
            preup = model.ms_close.doubleValue - preModel.ms_close.doubleValue;
        }else {
            predown = preModel.ms_close.doubleValue - model.ms_close.doubleValue;
        }
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    for (int i=0; i<self.m_data.count; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[i] intValue] range:range];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor],
                       [UIColor LABStock_accessoryThreeColor]];
    for (int i=0; i<self.m_data.count; i++) {
        [self drawLineWithCtx:ctx
                         rect:rect
                    xPosition:xPosition
                          max:max
                          min:min
                         data:self.m_data[i]
                       iFirst:[self.m_param[i] intValue]
                        color:color[i]];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor],
                           [UIColor LABStock_accessorySecondColor],
                           [UIColor LABStock_accessoryThreeColor]];
    
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
