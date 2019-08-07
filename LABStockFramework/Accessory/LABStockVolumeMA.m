//
//  LABStockVolumeMA.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVolumeMA.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@implementation LABStockVolumeMA

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels MATypes:(NSArray<NSNumber *> *)types {
    if ([super initWithLineModels:lineModels MATypes:types]) {
        self.precision = [LABStockVariable volumePrecision];
    }
    return self;
}

#pragma mark --外部方法

- (void)averageClose:(NSInteger)dayCount dataArray:(NSMutableArray *)dataArray {
    if (dayCount > self.lineModels.count || dayCount < 1) {
        return;
    }
    
    NSInteger i;
    CGFloat preVolume = 0;
    CGFloat sum = 0.0;
    for (i=0; i<dayCount-1; i++) {
        sum += self.lineModels[i].ms_volume;
    }
    for (i=dayCount-1; i<self.lineModels.count; i++) {
        sum -= preVolume;
        sum += self.lineModels[i].ms_volume;
        dataArray[i] = [NSNumber numberWithDouble:(CGFloat)sum/dayCount];
        preVolume = self.lineModels[i-dayCount+1].ms_volume;
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [super drawGraphWithCtx:ctx rect:rect xPosition:xPosition max:max min:min];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    CGFloat gap = 3;
    CGFloat x = gap;
    ///绘制VOL
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSString *name = @"VOL:";
    CGSize size = [LABStockVariable rectOfNSString:name attribute:attribute].size;
    [name drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
    x += size.width;
    
    id<LABStockDataProtocol> model = self.lineModels[index];
    NSString *value = [LABStockFormatUtils getStringWithDouble:model.ms_volume andScale:self.precision];
    size = [LABStockVariable rectOfNSString:value attribute:attribute].size;
    [value drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
    x += size.width+gap;
    for (int i=0; i<self.types.count; i++) {
        LABStockMAType type = [self.types[i] integerValue];
        NSString *name;
        UIColor *color;
        switch (type) {
            case LABStockMAType5:
                color = [UIColor LABStock_accessoryFirstColor];
                name = @"MA5:";
                break;
            case LABStockMAType10:
                color = [UIColor LABStock_accessorySecondColor];
                name = @"MA10:";
                break;
            case LABStockMAType30:
                color = [UIColor LABStock_accessoryThreeColor];
                name = @"MA30:";
                break;
            case LABStockMAType60:
                color = [UIColor LABStock_accessoryFourColor];
                name = @"MA60:";
                break;
        }
        attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:color};
        CGSize size = [LABStockVariable rectOfNSString:name attribute:attribute].size;
        [name drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width;
        
        NSArray *maValues = self.m_data[i];
        NSString *value = [LABStockFormatUtils getStringWithDouble:[maValues[index] doubleValue] andScale:self.precision];
        size = [LABStockVariable rectOfNSString:value attribute:attribute].size;
        [value drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width + gap;
    }
}

@end
