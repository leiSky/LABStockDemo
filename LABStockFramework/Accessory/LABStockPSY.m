//
//  LABStockPSY.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockPSY.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockPSY ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockPSY

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"PSY";
        self.m_param = @[@(12), @(24)];
        self.paramName = @[@"PSY12", @"PSY24"];
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
        if ([self.m_param[i] integerValue] <= [self.lineModels count] && [self.m_param[i] integerValue] > 0){
            [self getPSY:[self.m_param[i] integerValue] psy:self.m_data[i]];
        }else {
            [self.m_data[i] removeAllObjects];
        }
    }
}

- (void)getPSY:(NSInteger)n psy:(NSMutableArray *)psy {
    if (!psy) {return;}
    NSInteger i,j;
    CGFloat sum;
    
    for (sum = 0, i = 1; i < n; i++) {
        if (self.lineModels[i].ms_close.doubleValue > self.lineModels[i-1].ms_close.doubleValue)
            sum++;
    }
    for (i = n; i < [self.lineModels count]; i++) {
        if (self.lineModels[i].ms_close.doubleValue > self.lineModels[i-1].ms_close.doubleValue) {
            sum++;
        }
//        else if (self.lineModels[i].ms_close.doubleValue < self.lineModels[i-1].ms_close.doubleValue) {
//            sum--;
//        }
        psy[i] = [[NSNumber alloc] initWithDouble:(sum / n * 100)];
        j = i - n + 1;
        if (self.lineModels[j].ms_close.doubleValue > self.lineModels[j-1].ms_close.doubleValue) {
            sum--;
        }
//        else if (self.lineModels[j].ms_close.doubleValue < self.lineModels[j-1].ms_close.doubleValue) {
//            sum++;
//        }
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    for (int i=0; i<[self.m_param count]; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[i] integerValue] range:range];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor]];
    
    for (int i=0; i<[self.m_param count]; i++) {
        [self drawLineWithCtx:ctx
                         rect:rect
                    xPosition:xPosition
                          max:max
                          min:min
                         data:self.m_data[i]
                       iFirst:[self.m_param[i] integerValue]
                        color:color[i]];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor],
                           [UIColor LABStock_accessorySecondColor]];
    
    [textArray addObject:self.accessoryName];
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
