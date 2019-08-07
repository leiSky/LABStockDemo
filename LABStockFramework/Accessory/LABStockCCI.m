//
//  LABStockCCI.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockCCI.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import "LABStockFormatUtils.h"
#import "LABStockVariable.h"

@interface LABStockCCI ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;

@end

@implementation LABStockCCI

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"CCI";
        self.m_param = @[@(21)];
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    for (int i=0; i<2; i++) {
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
    
    int n = [self.m_param[0] intValue];
    if (n>self.lineModels.count) {
        return;
    }
    
    NSMutableArray *cci = self.m_data[0];
    NSMutableArray *ma = self.m_data[1];
    
    CGFloat sum = 0;
    for (int i=0; i<n-1; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        sum += (model.ms_high.doubleValue+model.ms_low.doubleValue+model.ms_close.doubleValue)/3.0;
    }
    CGFloat prec = 0;
    for (int i=n-1; i<self.lineModels.count; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        
        sum -= prec;
        sum += (model.ms_high.doubleValue+model.ms_low.doubleValue+model.ms_close.doubleValue)/3.0;
        ma[i] = @(sum/n);
        
        model = self.lineModels[i-n+1];
        prec = (model.ms_high.doubleValue+model.ms_low.doubleValue+model.ms_close.doubleValue)/3.0;
    }
    
    cci[n-2] = @0;
    for (int i=n-1; i<self.lineModels.count; i++) {
        sum = 0;
        for (int j=i-n+1; j<=i; j++) {
            id<LABStockDataProtocol> model = self.lineModels[j];
            sum += fabs((model.ms_high.doubleValue+model.ms_low.doubleValue+model.ms_close.doubleValue)/3.0 - [ma[i] doubleValue]);
        }
        if (sum == 0) {
            cci[i] = cci[i-1];
        }else {
            id<LABStockDataProtocol> model = self.lineModels[i];
            CGFloat temp = (CGFloat)(((model.ms_high.doubleValue+model.ms_low.doubleValue+model.ms_close.doubleValue)/3.0 - [ma[i] doubleValue]) / (0.015 * sum / n));
            cci[i] = [NSNumber numberWithDouble:temp];
        }
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] intValue]-1 range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0]
                   iFirst:[self.m_param[0]
                           intValue]-1
                    color:[UIColor LABStock_accessoryFirstColor]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    CGFloat gap = 3;
    CGFloat x = gap;
    NSArray *dataArray = self.m_data[0];
    double value = [dataArray[index] doubleValue];
    NSString *drawStr = [NSString stringWithFormat:@"%@:%@",self.accessoryName, [LABStockFormatUtils getStringWithDouble:value andScale:self.precision]];
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont], NSForegroundColorAttributeName: [UIColor LABStock_accessoryFirstColor]};
    [drawStr drawAtPoint:CGPointMake(x, 0) withAttributes:attribute];
}

@end
