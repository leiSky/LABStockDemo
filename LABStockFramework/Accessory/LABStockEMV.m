//
//  LABStockEMV.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockEMV.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockEMV ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockEMV

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"EMV";
        self.m_param = @[@(14), @(9)];
        self.paramName = @[@"", @"EMVMA"];
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
    int n1 = [self.m_param[0] intValue];
    int n2 = [self.m_param[1] intValue];
    if (n1 > self.lineModels.count) {
        return;
    }
    
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    NSMutableArray *emv = self.m_data[0];
    NSMutableArray *ma = self.m_data[1];
    
    emv[n1-1] =  @0;
    for (int i=n1; i<self.lineModels.count; i++) {
        emv[i] = @0;
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-n1];
        if (self.lineModels[i].ms_volume > 0) {
            CGFloat temp = (model.ms_high.doubleValue + model.ms_low.doubleValue - preModel.ms_high.doubleValue - preModel.ms_low.doubleValue) / 2 * (model.ms_high.doubleValue - model.ms_low.doubleValue);
            emv[i] = [[NSNumber alloc] initWithDouble:temp];
        }
    }
    if (n2<=self.lineModels.count) {
        [self averageData:n1 count:self.lineModels.count dayCount:n2 source:emv destination:ma];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] intValue] range:range];
    [self getValueMaxMin:self.m_data[1] iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1 range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0]
                   iFirst:[self.m_param[0] intValue]
                    color:[UIColor LABStock_accessoryFirstColor]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1
                    color:[UIColor LABStock_accessorySecondColor]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableArray *textColor = [NSMutableArray array];
    [textColor addObject:[UIColor LABStock_textColor]];
    [textColor addObject:[UIColor LABStock_accessoryFirstColor]];
    [textColor addObject:[UIColor LABStock_accessorySecondColor]];
    
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
