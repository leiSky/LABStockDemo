//
//  LABStockBOLL.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockBOLL.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockBOLL ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockBOLL

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"BOLL";
        self.m_param = @[@(10)];
        self.paramName = @[@"MID", @"UPPER", @"LOWER"];
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
    
    int i;
    int n = [self.m_param[0] intValue];
    if (n>self.lineModels.count || n<1 || n+n-2>=self.lineModels.count) {
        return;
    }
    ///用零填充
    for (i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    
    NSMutableArray *average = self.m_data[0];
    NSMutableArray *up = self.m_data[1];
    NSMutableArray *down = self.m_data[2];
    CGFloat sum=0, value, preValue;
    [self averageClose:n dataArray:average];
    for (i=n-1; i<n+n-2; i++) {
        value = self.lineModels[i].ms_close.doubleValue-[average[i] doubleValue];
        sum += value*value;
    }
    preValue =0;
    for (i=n+n-2; i<self.lineModels.count; i++) {
        sum -= preValue;
        value = self.lineModels[i].ms_close.doubleValue-[average[i] doubleValue];
        sum += value * value;
        
        value = ((CGFloat)sqrt(sum/n))*1.805f;
        up[i] = @([average[i] doubleValue]+value);
        down[i] = @([average[i] doubleValue]-value);
        
        value = self.lineModels[i-n+1].ms_close.doubleValue - [average[i-n+1] doubleValue];
        preValue = value * value;
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    [super getMaxMin:range];
    for (int i=0; i<self.m_data.count; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[0] intValue]*2-2 range:range];
    }}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawUSAGraphWithCtx:ctx rect:rect xPosition:xPosition max:max min:min];
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
                       iFirst:[self.m_param[0] intValue]*2-2
                        color:color[i]];
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
