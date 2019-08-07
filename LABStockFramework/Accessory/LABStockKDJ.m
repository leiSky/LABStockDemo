//
//  LABStockKDJ.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockKDJ.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockKDJ ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockKDJ

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"KDJ";
        self.m_param = @[@(9), @(3), @(3)];
        self.paramName = @[@"K", @"D", @"J"];
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
    int n3 = [self.m_param[2] intValue];
    
    if (n1 > self.lineModels.count) {
        return;
    }
    
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    NSMutableArray *kvalue = self.m_data[0];
    NSMutableArray *dvalue = self.m_data[1];
    NSMutableArray *jvalue = self.m_data[2];
    
    CGFloat maxhigh, minlow, rsv, prersv;
    
    maxhigh = self.lineModels[n1-1].ms_high.doubleValue;
    minlow = self.lineModels[n1-1].ms_low.doubleValue;
    for (int j=n1-1; j>=0; j--) {
        id<LABStockDataProtocol> model = self.lineModels[j];
        if (maxhigh<model.ms_high.doubleValue) {
            maxhigh = model.ms_high.doubleValue;
        }if (minlow<model.ms_low.doubleValue) {
            minlow = model.ms_low.doubleValue;
        }
    }
    if (maxhigh <= minlow) {
        rsv = 50;
    }else {
        rsv = (self.lineModels[n1-1].ms_close.doubleValue-minlow) / (maxhigh - minlow) * 100;
    }
    prersv = rsv;
    kvalue[n1-1] = [[NSNumber alloc] initWithDouble:rsv];
    dvalue[n1-1] = [[NSNumber alloc] initWithDouble:rsv];
    jvalue[n1-1] = [[NSNumber alloc] initWithDouble:rsv];
    for (int i = 0; i < n1; i++) {
        kvalue[i] = [[NSNumber alloc] initWithDouble:0];
        dvalue[i] =[[NSNumber alloc] initWithDouble:0];
        jvalue[i] = [[NSNumber alloc] initWithDouble:0];
    }
    for (int i=n1; i<self.lineModels.count; i++) {
        id<LABStockDataProtocol> iModel = self.lineModels[i];
        maxhigh = iModel.ms_high.doubleValue;
        minlow = iModel.ms_low.doubleValue;
        for (int j=i-1; j>i-n1; j--) {
            id<LABStockDataProtocol> jmodel = self.lineModels[j];
            if (maxhigh < jmodel.ms_high.doubleValue) {
                maxhigh = jmodel.ms_high.doubleValue;
            }
            if (minlow>jmodel.ms_low.doubleValue) {
                minlow = jmodel.ms_low.doubleValue;
            }
        }
        if (maxhigh <= minlow) {
            rsv = prersv;
        }else {
            prersv = rsv;
            rsv = (iModel.ms_close.doubleValue-minlow) / (maxhigh - minlow) * 100;
        }
        kvalue[i] = [[NSNumber alloc] initWithDouble:([kvalue[i-1] doubleValue] * (n2-1) / n2 + rsv / n2)];;
        dvalue[i] = [[NSNumber alloc] initWithDouble:([kvalue[i] doubleValue] / n3 + [dvalue[i-1] doubleValue] * (n3-1) / n3)];
        jvalue[i] = [[NSNumber alloc] initWithDouble:(3 * [kvalue[i] doubleValue] - 2 * [dvalue[i] doubleValue])];
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
