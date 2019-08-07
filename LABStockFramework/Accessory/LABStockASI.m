//
//  LABStockASI.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockASI.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@implementation LABStockASI

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"ASI";
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
    NSMutableArray *asi = [NSMutableArray arrayWithCapacity:self.lineModels.count];
    [self.m_data addObject:asi];
    
    CGFloat a, b, c, d, e, f, g, x, r, k, si;
    asi[0] = @(0);
    si = 0;
    for (int i=1; i<self.lineModels.count; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        a = fabs(model.ms_high.doubleValue - preModel.ms_close.doubleValue);
        b = fabs(model.ms_low.doubleValue - preModel.ms_close.doubleValue);
        c = fabs(model.ms_high.doubleValue - preModel.ms_low.doubleValue);
        d = fabs(preModel.ms_close.doubleValue - preModel.ms_open.doubleValue);
        e = model.ms_close.doubleValue - preModel.ms_close.doubleValue;
        f = model.ms_close.doubleValue - model.ms_open.doubleValue;
        g = preModel.ms_close.doubleValue - preModel.ms_open.doubleValue;
        x = e + f / 2 + g;
        r = 0;
        if (a >= b && a >= c) {
            r = a + b / 2 + d / 4;
        }
        if (b >= a && b >= c) {
            r = b + a / 2 + d / 4;
        }
        if (c >= a && c >= b) {
            r = c + d / 4;
        }
        k = fmax(a, b);
        if (k != 0) {
            si = 50 * x / r * k / 3;
        }
        asi[i] = [[NSNumber alloc] initWithDouble:([asi[i - 1] doubleValue] + si)];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:1 range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:self.maxValue
                      min:self.minValue
                     data:self.m_data[0]
                   iFirst:1
                    color:[UIColor LABStock_accessoryFirstColor]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    CGFloat gap = 3;
    CGFloat x = gap;
    double value = [self.m_data[0][index] doubleValue];
    NSString *drawStr = [NSString stringWithFormat:@"%@:%@",self.accessoryName, [LABStockFormatUtils getStringWithDouble:value andScale:self.precision]];
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont], NSForegroundColorAttributeName: [UIColor LABStock_accessoryFirstColor]};
    [drawStr drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
}

@end
