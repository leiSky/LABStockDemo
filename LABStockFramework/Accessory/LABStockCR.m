//
//  LABStockCR.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockCR.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockFormatUtils.h"
#import "LABStockVariable.h"

@interface LABStockCR ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockCR

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"CR";
        self.m_param = @[@(26), @(10), @(20), @(40)];
        self.paramName = @[@"CR", @"a", @"b", @"c"];
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
    
    NSInteger n = [self.m_param[0] integerValue];
    [self getCR:n array:self.m_data[0]];
    
    [self averageData:n count:self.lineModels.count dayCount:[self.m_param[1] integerValue] source:self.m_data[0] destination:self.m_data[1]];
    [self averageData:n count:self.lineModels.count dayCount:[self.m_param[2] integerValue] source:self.m_data[0] destination:self.m_data[2]];
    [self averageData:n count:self.lineModels.count dayCount:[self.m_param[3] integerValue] source:self.m_data[0] destination:self.m_data[3]];
}

- (void)getCR:(NSInteger)n array:(NSMutableArray *)cr {
    CGFloat upsum, downsum;
    CGFloat precr;
    CGFloat value;
    
    if ([self.lineModels count] < n) {return;}
    
    upsum = downsum = 0;
    for (int i = 1; i < n; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        value = (preModel.ms_high.doubleValue + preModel.ms_low.doubleValue) / 2;
        upsum += (model.ms_high.doubleValue - value > 0 ? model.ms_high.doubleValue - value : 0);
        downsum += (value - model.ms_low.doubleValue > 0 ? value - model.ms_low.doubleValue : 0);
    }
    precr = 0;
    for (NSInteger i = n; i < [self.lineModels count]; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        value = (preModel.ms_high.doubleValue + preModel.ms_low.doubleValue) / 2;
        upsum += (model.ms_high.doubleValue - value > 0 ? model.ms_high.doubleValue - value : 0);
        downsum += (value - model.ms_low.doubleValue > 0 ? value - model.ms_low.doubleValue : 0);
        cr[i] = [[NSNumber alloc] initWithDouble:precr];
        if (downsum != 0) {
            cr[i] =[[NSNumber alloc] initWithDouble:upsum / downsum * 100];
        }
        precr = [cr[i] doubleValue];
        NSInteger j = i - n + 1;
        id<LABStockDataProtocol> jModel = self.lineModels[j];
        id<LABStockDataProtocol> preJModel = self.lineModels[j-1];
        value = (preJModel.ms_high.doubleValue + preJModel.ms_low.doubleValue) / 2;
        upsum -= (jModel.ms_high.doubleValue - value > 0 ? jModel.ms_high.doubleValue - value : 0);
        downsum -= (value - jModel.ms_low.doubleValue > 0 ? value - jModel.ms_low.doubleValue : 0);
    }
}

#pragma mark --外部方法
- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] intValue] range:range];
    [self getValueMaxMin:self.m_data[1] iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1 range:range];
    [self getValueMaxMin:self.m_data[2] iFirst:[self.m_param[0] intValue]+[self.m_param[2] intValue]-1 range:range];
    [self getValueMaxMin:self.m_data[3] iFirst:[self.m_param[0] intValue]+[self.m_param[3] intValue]-1 range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor],
                       [UIColor LABStock_accessoryThreeColor],
                       [UIColor LABStock_accessoryFourColor]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0]
                   iFirst:[self.m_param[0] intValue]
                    color:color[0]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1
                    color:color[1]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[2]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[2] intValue]-1
                    color:color[2]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[3]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[3] intValue]-1
                    color:color[3]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSArray *textColor = @[[UIColor LABStock_textColor],
                           [UIColor LABStock_accessoryFirstColor],
                           [UIColor LABStock_accessorySecondColor],
                           [UIColor LABStock_accessoryThreeColor],
                           [UIColor LABStock_accessoryFourColor]];
    
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
