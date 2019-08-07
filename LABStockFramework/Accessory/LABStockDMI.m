//
//  LABStockDMI.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockDMI.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockDataProtocol.h"
#import "LABStockFormatUtils.h"

@interface LABStockDMI ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockDMI

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"DMI";
        self.m_param = @[@(7), @(6), @(5)];
        self.paramName = @[@"+DI", @"-DI", @"ADX", @"ADXR"];
        self.precision = [LABStockVariable pricePrecision];
        [self calculate];
    }
    return self;
}

#pragma mark --内部方法

- (void)calculate {
    for (int i=0; i<5; i++) {
        [self.m_data addObject:[NSMutableArray array]];
    }
    if (!self.m_data || self.m_data.count <= 0) {
        return;
    }
    int n1 = [self.m_param[0] intValue];
    int n2 = [self.m_param[1] intValue];
    int n3 = [self.m_param[2] intValue];
    
    if (self.lineModels.count < n1) {
        return;
    }
    ///用零填充
    for (int i=0; i<self.m_data.count; i++) {
        for (int j=0; j<self.lineModels.count; j++) {
            [self.m_data[i] addObject:@0];
        }
    }
    
    CGFloat a, b, c, prezDI, prefDI;
    NSMutableArray *zDI = self.m_data[0];
    NSMutableArray *fDI = self.m_data[1];
    NSMutableArray *TR = self.m_data[2];
    NSMutableArray *ADX = self.m_data[2];
    NSMutableArray *ADXR = self.m_data[3];
    NSMutableArray *zDM = self.m_data[3];
    NSMutableArray *fDM = self.m_data[4];
    NSMutableArray *DX = self.m_data[4];
    /// 求出TR、+DM、-DM
    for (int i=1; i<self.lineModels.count; i++) {
        a = fabs(self.lineModels[i].ms_high.doubleValue - self.lineModels[i].ms_low.doubleValue);
        b = fabs(self.lineModels[i].ms_high.doubleValue - self.lineModels[i-1].ms_close.doubleValue);
        c = fabs(self.lineModels[i].ms_low.doubleValue - self.lineModels[i-1].ms_close.doubleValue);
        TR[i] = [[NSNumber alloc] initWithDouble:fmax(a, fmax(b, c))];
        
        a = self.lineModels[i].ms_high.doubleValue - self.lineModels[i-1].ms_high.doubleValue;
        b = self.lineModels[i-1].ms_low.doubleValue - self.lineModels[i].ms_low.doubleValue;
        a = a <= 0 ? 0 : a;
        b = b <= 0 ? 0 : b;
        zDM[i] =  [[NSNumber alloc] initWithDouble:0];
        fDM[i] =  [[NSNumber alloc] initWithDouble:0];
        if (a > b) {
            zDM[i] = [[NSNumber alloc] initWithDouble:a];
        }else if (a < b) {
            fDM[i] = [[NSNumber alloc] initWithDouble:b];
        }
    }
    // 求出+DI、-DI
    a = b = c = 0;
    for (int i=1; i<n1; i++) {
        a += [TR[i] doubleValue];
        b += [zDM[i] doubleValue];
        c += [fDM[i] doubleValue];
    }
    prezDI = prefDI = 0;
    for (int i=n1; i<self.lineModels.count; i++) {
        a += [TR[i] doubleValue];
        b += [zDM[i] doubleValue];
        c += [fDM[i] doubleValue];
        zDI[i] =  [[NSNumber alloc] initWithDouble:prezDI];
        fDI[i] =  [[NSNumber alloc] initWithDouble:prefDI];
        if (a != 0) {
            zDI[i] = [[NSNumber alloc] initWithDouble:b / a * 100];// ＋DI
            fDI[i] = [[NSNumber alloc] initWithDouble:c / a * 100];// －DI
        }
        prezDI = [zDI[i] doubleValue];
        prefDI = [fDI[i] doubleValue];
        int j = i - n1 + 1;
        a -= [TR[j] doubleValue];
        b -= [zDM[j] doubleValue];
        c -= [fDM[j] doubleValue];
    }
    // 求出DX
    for (int i=n1; i<self.lineModels.count; i++) {
        if ([zDI[i] doubleValue] + [fDI[i] doubleValue] != 0) {
            DX[i] = [[NSNumber alloc] initWithDouble:(float)(fabs([zDI[i] doubleValue] - [fDI[i] doubleValue]) / fabs([zDI[i] doubleValue] + [fDI[i] doubleValue]) * 100)];
        }else {
            DX[i] = [[NSNumber alloc] initWithDouble:0];
        }
    }
    // 求出ADX
    [self averageData:n1 count:self.lineModels.count dayCount:n2 source:DX destination:ADX];
    // 求出ADXR
    for (int i=n1+n2+n3-1; i<self.lineModels.count; i++) {
        ADXR[i] = [[NSNumber alloc] initWithDouble:([ADX[i] doubleValue]  + [ADX[i - n3] doubleValue]) / 2];
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    [self getValueMaxMin:self.m_data[0] iFirst:[self.m_param[0] intValue] range:range];
    [self getValueMaxMin:self.m_data[1] iFirst:[self.m_param[0] intValue] range:range];
    [self getValueMaxMin:self.m_data[2] iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1 range:range];
    [self getValueMaxMin:self.m_data[3] iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]+[self.m_param[2] intValue]-1 range:range];
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
                   iFirst:[self.m_param[0] intValue]
                    color:[UIColor LABStock_accessorySecondColor]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[2]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]-1
                    color:[UIColor LABStock_accessoryThreeColor]];
    [self drawLineWithCtx:ctx
                     rect:rect
                xPosition:xPosition
                      max:max
                      min:min
                     data:self.m_data[3]
                   iFirst:[self.m_param[0] intValue]+[self.m_param[1] intValue]+[self.m_param[2] intValue]-1
                    color:[UIColor LABStock_accessoryFourColor]];
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index {
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableArray *textColor = [NSMutableArray array];
    [textColor addObject:[UIColor LABStock_textColor]];
    [textColor addObject:[UIColor LABStock_accessoryFirstColor]];
    [textColor addObject:[UIColor LABStock_accessorySecondColor]];
    [textColor addObject:[UIColor LABStock_accessoryThreeColor]];
    [textColor addObject:[UIColor LABStock_accessoryFourColor]];
    
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
