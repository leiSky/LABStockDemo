//
//  LABStockWR.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockWR.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockWR()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockWR

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"W%R";
        self.m_param = @[@(14), @(6)];
        self.paramName = @[@"WR1", @"WR2"];
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
        [self getW_R:[self.m_param[i] intValue] wms:self.m_data[i]];
    }
}

- (void)getW_R:(NSInteger)n wms:(NSMutableArray *)wms {
    if (n>self.lineModels.count) {
        [wms removeAllObjects];
        return;
    }
    
    CGFloat maxhigh, minlow;
    for (NSInteger i=n-1; i<self.lineModels.count; i++) {
        id<LABStockDataProtocol> iModel = self.lineModels[i];
        maxhigh = iModel.ms_high.doubleValue;
        minlow = iModel.ms_low.doubleValue;
        for (NSInteger j=i-1; j>i-n; j--) {
            id<LABStockDataProtocol> jModel = self.lineModels[j];
            maxhigh = fmax(maxhigh, jModel.ms_high.doubleValue);
            minlow = fmin(minlow, jModel.ms_low.doubleValue);
        }
        if (maxhigh - minlow == 0) {
            if (i-1 == 0) {
                wms[i] = [[NSNumber alloc] initWithDouble:-50];
            }else {
                wms[i] = wms[i-1];
            }
        }else {
            wms[i] = [[NSNumber alloc] initWithDouble:(-(maxhigh - iModel.ms_close.doubleValue) / (maxhigh - minlow) * 100)];
        }
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    for (int i=0; i<self.m_param.count; i++) {
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
