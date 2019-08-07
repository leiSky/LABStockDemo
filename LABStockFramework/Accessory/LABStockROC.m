//
//  LABStockROC.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockROC.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockROC ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockROC

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"ROC";
        self.m_param = @[@(12), @(6)];
        self.paramName = @[@"", @"ROCMA"];
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
    int m = [self.m_param[1] intValue];
    if (n > self.lineModels.count) {
        return;
    }
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    
    NSMutableArray* roc = self.m_data[0];
    roc[n - 1] = [[NSNumber alloc] initWithDouble:0];
    for (NSInteger i = n; i < [self.lineModels count]; i++) {
        if (self.lineModels[i-n].ms_close.doubleValue == 0) {
            roc[i] = roc[i - 1];
        }else {
            roc[i] = [[NSNumber alloc] initWithDouble:((self.lineModels[i].ms_close.doubleValue / self.lineModels[i-n].ms_close.doubleValue - 1) * 100)];
        }
    }
    [self averageData:1 count:self.lineModels.count dayCount:m source:roc destination:self.m_data[1]];
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] integerValue] range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor]];
    
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0]
                   iFirst:[self.m_param[1] integerValue]
                    color:color[0]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[0] integerValue]+[self.m_param[1] integerValue]
                    color:color[1]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor],
                           [UIColor LABStock_accessorySecondColor]];
    
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
