//
//  LABStockVR.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVR.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockVR ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockVR

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"VR";
        self.m_param = @[@(25), @(5)];
        self.paramName = @[@"", @"MA"];
        self.precision = [LABStockVariable volumePrecision];
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
    NSInteger n1 = [self.m_param[0] integerValue];
    NSInteger n2 = [self.m_param[1] integerValue];
    if (n1 > self.lineModels.count) {
        return;
    }
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    
    NSMutableArray *vr = self.m_data[0];
    NSMutableArray *ma = self.m_data[1];
    CGFloat up, down, middle;
    
    up = down = middle = 0;
    if ([self.lineModels count] < n1)
        return;
    vr[n1 - 2] = [[NSNumber alloc] initWithDouble:100];
    for (int i = 1; i < n1; i++)   {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        if (model.ms_close.doubleValue == preModel.ms_close.doubleValue) {
            middle += model.ms_volume;
        }else if (model.ms_close.doubleValue > preModel.ms_close.doubleValue) {
            up += model.ms_volume;
        }else {
            down += model.ms_volume;
        }
    }
    if (down + middle / 2 == 0) {
        vr[n1 - 1] = vr[n1 - 2];
    }else {
        vr[n1 - 1] = [[NSNumber alloc] initWithDouble:((up  + middle / 2) / (down + middle / 2))];
    }
    for (NSInteger i = n1; i < [self.lineModels count]; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        if (model.ms_close.doubleValue == preModel.ms_close.doubleValue) {
            middle += model.ms_volume;
        }else if (model.ms_close.doubleValue > preModel.ms_close.doubleValue) {
            up += model.ms_volume;
        }else {
            down += model.ms_volume;
        }
        
        if (down + middle / 2 == 0) {
            vr[i] = vr[i - 1];
        }else {
            vr[i] = [[NSNumber alloc] initWithDouble:((up  + middle / 2) / (down + middle / 2) * 100)];
        }
        
        if (self.lineModels[i-n1+1].ms_close.doubleValue == self.lineModels[i-n1].ms_close.doubleValue) {
            middle -= self.lineModels[i-n1+1].ms_volume;
        }else if (self.lineModels[i-n1+1].ms_close.doubleValue > self.lineModels[i-n1].ms_close.doubleValue) {
            up -= self.lineModels[i-n1+1].ms_volume;
        }else {
            down -= self.lineModels[i-n1+1].ms_volume;
        }
    }
    [self averageData:n1 count:self.lineModels.count dayCount:n2 source:vr destination:ma];
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] integerValue] range:range];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor]];
    
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[0] iFirst:[self.m_param[0] integerValue]
                    color:color[0]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[1]
                   iFirst:[self.m_param[0] integerValue]+[self.m_param[1] integerValue]-1
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
