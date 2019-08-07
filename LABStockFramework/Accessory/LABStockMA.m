//
//  LABStockMA.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockMA.h"
#import "LABStockVariable.h"
#import "UIColor+LABStock.h"
#import "LABStockFormatUtils.h"

@interface LABStockMA ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *m_param;

@end

@implementation LABStockMA

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels MATypes:(NSArray<NSNumber *> *)types {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"MA";
        _types = types;
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    if (!self.lineModels || self.lineModels.count <= 0) {
        return;
    }
    self.m_param = [NSMutableArray array];
    for (NSNumber *num in self.types) {
        [self.m_param addObject:num];
        ///用0填充
        NSMutableArray *array = [NSMutableArray array];
        [self.m_data addObject:array];
        for (int i=0; i<self.lineModels.count; i++) {
            [array addObject:[NSNumber numberWithDouble:0.0f]];
        }
        [self averageClose:[num integerValue] dataArray:array];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    for (int i=0; i<self.m_data.count; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[i] integerValue] range:range];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    for (int k=0; k<self.m_data.count; k++) {
        UIColor *color;
        switch ([self.types[k] integerValue]) {
            case LABStockMAType5:
                color = [UIColor LABStock_accessoryFirstColor];
                break;
            case LABStockMAType10:
                color = [UIColor LABStock_accessorySecondColor];
                break;
            case LABStockMAType30:
                color = [UIColor LABStock_accessoryThreeColor];
                break;
            case LABStockMAType60:
                color = [UIColor LABStock_accessoryFourColor];
                break;
        }
        [self drawLineWithCtx:ctx
                         rect:rect
                    xPosition:xPosition
                          max:max
                          min:min
                         data:self.m_data[k]
                       iFirst:[self.m_param[k] integerValue]-1
                        color:color];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    CGFloat gap = 3;
    CGFloat x = gap;
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
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:color};
        CGSize size = [LABStockVariable rectOfNSString:name attribute:attribute].size;
        [name drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width;
        
        NSArray *maValues = self.m_data[i];
        NSString *value = [NSString stringWithFormat:@"%@", [LABStockFormatUtils getStringWithDouble:[maValues[index] doubleValue] andScale:self.precision]];
        size = [LABStockVariable rectOfNSString:value attribute:attribute].size;
        [value drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
        x += size.width + gap;
    }
}

@end
