//
//  LABStockTRIX.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTRIX.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockTRIX ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockTRIX

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"TRIX";
        self.m_param = @[@(12), @(9)];
        self.paramName = @[@"", @""];
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
    }
    [self getEXPMA:[self.m_param[0] integerValue] expma:self.m_data[0]];
    [self averageData:[self.m_param[0] integerValue]-1 count:self.lineModels.count dayCount:[self.m_param[0] integerValue] source:self.m_data[0] destination:self.m_data[1]];
    [self averageData:[self.m_param[0] integerValue]*2-2 count:self.lineModels.count dayCount:[self.m_param[0] integerValue] source:self.m_data[1] destination:self.m_data[0]];
    [self averageData:[self.m_param[0] integerValue]*3-3 count:self.lineModels.count dayCount:[self.m_param[1] integerValue] source:self.m_data[0] destination:self.m_data[1]];
}

- (void)getEXPMA:(NSInteger)n expma:(NSMutableArray *)expma {
    CGFloat xs = 2.0f / (n + 1);
    expma[0] = [[NSNumber alloc] initWithDouble:self.lineModels[0].ms_close.doubleValue];
    for (int i = 1; i < [self.lineModels count]; i++) {
        expma[i] =  [[NSNumber alloc] initWithDouble:((self.lineModels[i].ms_close.doubleValue - [expma[i - 1] doubleValue]) * xs + [expma[i - 1] doubleValue])];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] integerValue]*3-3 range:range];
    [self getValueMaxMin:self.m_data[1] iFirst:[self.m_param[0] integerValue]*3-3+[self.m_param[1] integerValue]-1 range:range];
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
                   iFirst:[self.m_param[0] integerValue]*3-3
                    color:color[0]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[0] integerValue]*3-3+[self.m_param[1] integerValue]-1
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
