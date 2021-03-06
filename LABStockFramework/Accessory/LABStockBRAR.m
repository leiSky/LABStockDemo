//
//  LABStockBRAR.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockBRAR.h"
#import "LABStockDataProtocol.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockBRAR ()

@property (nonatomic, strong) NSArray<NSNumber *> *m_param;
@property (nonatomic, strong) NSArray<NSString *> *paramName;

@end

@implementation LABStockBRAR

#pragma mark --初始化方法

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"BRAR";
        self.m_param = @[@(26)];
        self.paramName = @[@"AR", @"BR"];
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
    [self getAR:[self.m_param[0] integerValue] array:self.m_data[0]];
    [self getBR:[self.m_param[0] integerValue] array:self.m_data[1]];
}

- (void)getAR:(NSInteger)n array:(NSMutableArray *)ar {
    CGFloat upsum, downsum;
    CGFloat prear;
    
    if ([self.lineModels count] < n) {return;}
    
    upsum = downsum = 0;
    for (int i = 1; i < n; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        upsum += model.ms_high.doubleValue - model.ms_open.doubleValue;
        downsum += model.ms_open.doubleValue - model.ms_low.doubleValue;
    }
    prear = 0;
    for (NSInteger i = n; i < [self.lineModels count]; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        upsum += model.ms_high.doubleValue - model.ms_open.doubleValue;
        downsum += model.ms_open.doubleValue - model.ms_low.doubleValue;
        ar[i] = [[NSNumber alloc] initWithDouble:prear];
        if (downsum != 0) {
            ar[i] = [[NSNumber alloc] initWithDouble:upsum / downsum * 100];
        }
        prear = [ar[i] doubleValue];
        NSInteger j = i - n + 1;
        id<LABStockDataProtocol> jModel = self.lineModels[j];
        upsum -= jModel.ms_high.doubleValue - jModel.ms_open.doubleValue;
        downsum -= jModel.ms_open.doubleValue - jModel.ms_low.doubleValue;
    }
}

- (void)getBR:(NSInteger)n array:(NSMutableArray *)br {
    CGFloat upsum, downsum;
    CGFloat prebr;
    CGFloat value;
    
    if ([self.lineModels count] < n) {return;}
    
    upsum = downsum = 0;
    for (int i = 1; i < n; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        value = model.ms_high.doubleValue - preModel.ms_close.doubleValue;
        upsum += value <= 0 ? 0 : value;
        value = preModel.ms_close.doubleValue - model.ms_low.doubleValue;
        downsum += value <= 0 ? 0 : value;
    }
    prebr = 0;
    for (NSInteger i = n; i < [self.lineModels count]; i++) {
        id<LABStockDataProtocol> model = self.lineModels[i];
        id<LABStockDataProtocol> preModel = self.lineModels[i-1];
        value = model.ms_high.doubleValue - preModel.ms_close.doubleValue;
        upsum += value <= 0 ? 0 : value;
        value = preModel.ms_close.doubleValue - model.ms_low.doubleValue;
        downsum += value <= 0 ? 0 : value;
        br[i] =[[NSNumber alloc] initWithDouble:prebr];
        if (downsum != 0) {
            br[i] = [[NSNumber alloc] initWithDouble:upsum / downsum * 100];
        }
        prebr = [br[i] doubleValue];
        NSInteger j = i - n + 1;
        id<LABStockDataProtocol> jModel = self.lineModels[j];
        id<LABStockDataProtocol> preJModel = self.lineModels[j-1];
        value = jModel.ms_high.doubleValue - preJModel.ms_close.doubleValue;
        upsum -= value <= 0 ? 0 : value;
        value = preJModel.ms_close.doubleValue - jModel.ms_low.doubleValue;
        downsum -= value <= 0 ? 0 : value;
    }
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    if (range.length <= 0) {
        return;
    }
    
    for (int i=0; i<self.paramName.count; i++) {
        [self getValueMaxMin:self.m_data[i] iFirst:[self.m_param[0] intValue] range:range];
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray *color = @[[UIColor LABStock_accessoryFirstColor],
                       [UIColor LABStock_accessorySecondColor]];
    for (int i=0; i<self.m_data.count; i++) {
        [self drawLineWithCtx:ctx
                         rect:rect
                    xPosition:xPosition
                          max:max
                          min:min
                         data:self.m_data[i]
                       iFirst:[self.m_param[0] intValue]
                        color:color[i]];
    }
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
