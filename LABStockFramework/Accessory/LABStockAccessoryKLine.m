//
//  LABStockAccessoryKLine.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryKLine.h"
#import "LABStockDataProtocol.h"
#import "LABStockKLinePositionModel.h"
#import "LABStockVariable.h"
#import "UIColor+LABStock.h"

@interface LABStockAccessoryKLine ()

@property (nonatomic, strong) NSMutableArray<LABStockKLinePositionModel *> *drawPositionModels;

@end

@implementation LABStockAccessoryKLine

- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels {
    if ([super initWithLineModels:lineModels]) {
        self.accessoryName = @"K-Line";
    }
    return self;
}

#pragma mark --外部方法

- (void)getMaxMin:(NSRange)range {
    NSArray<id<LABStockDataProtocol>> *drawModels = [self.lineModels subarrayWithRange:range];
    CGFloat max = [[[drawModels valueForKeyPath:@"ms_high"] valueForKeyPath:@"@max.doubleValue"] doubleValue];
    CGFloat min =  [[[drawModels valueForKeyPath:@"ms_low"] valueForKeyPath:@"@min.doubleValue"] doubleValue];
    if (max > self.maxValue) {
        self.maxValue = max;
    }
    if (min < self.minValue) {
        self.minValue = min;
    }
}

- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray<id<LABStockDataProtocol>> *drawModels = [self.lineModels subarrayWithRange:self.range];
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawModels maxValue:max minValue:min rect:rect];
    [self drawKLine:ctx rect:rect drawLineModels:drawModels];
}

- (void)drawUSAGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min {
    NSArray<id<LABStockDataProtocol>> *drawModels = [self.lineModels subarrayWithRange:self.range];
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawModels maxValue:max minValue:min rect:rect];
    [self drawUSAKLine:ctx rect:rect drawLineModels:drawModels];
}

#pragma mark --内部方法

///将数据转换为坐标
///@param startX x起始坐标
///@param drawLineModels 绘制的数据
///@param maxValue 数据最大范围
///@param minValue 数据最小范围
///@param rect 绘制的范围
///@return K线的数据坐标数组<LABStockKLinePositionModel *>
- (NSArray<LABStockKLinePositionModel *> *)convertToPositionModelsWithXPosition:(CGFloat)startX
                                                                 drawLineModels:(NSArray <id<LABStockDataProtocol>>*)drawLineModels
                                                                       maxValue:(CGFloat)maxValue
                                                                       minValue:(CGFloat)minValue
                                                                           rect:(CGRect)rect {
    if (!drawLineModels) {
        return nil;
    }
    [self.drawPositionModels removeAllObjects];
    CGFloat minY = self.minY;
    CGFloat maxY = self.maxY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    if (unitValue == 0) {
        unitValue = 0.01f;
    }
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    [drawLineModels enumerateObjectsUsingBlock:^(id<LABStockDataProtocol> obj, NSUInteger idx, BOOL *stop) {
        CGFloat xPosition = startX + idx * (lineGap + lineWidth);
        CGPoint highPonit = CGPointMake(xPosition, ABS(maxY - (obj.ms_high.doubleValue - minValue)/unitValue));
        CGPoint lowPoint = CGPointMake(xPosition, ABS(maxY - (obj.ms_low.doubleValue - minValue)/unitValue));
        CGPoint openPoint = CGPointMake(xPosition, ABS(maxY - (obj.ms_open.doubleValue - minValue)/unitValue));
        CGFloat closePointY = ABS(maxY - (obj.ms_close.doubleValue - minValue)/unitValue);
        
        ///调整开盘收盘
        if (ABS(closePointY - openPoint.y) < LABStockLineMinThick) {//蜡烛厚度比最小还小
            if (openPoint.y > closePointY) {//开盘大于收盘,开盘=收盘+最小厚度
                openPoint.y = closePointY + LABStockLineMinThick;
            }else if (openPoint.y < closePointY) {//开盘小于收盘,收盘=开盘+最小厚度
                closePointY = openPoint.y + LABStockLineMinThick;
            }else {//开盘等于收盘
                if (idx > 0) {//第一个以后
                    id<LABStockDataProtocol> preModel = drawLineModels[idx-1];//前一条数据
                    if (obj.ms_open.doubleValue < preModel.ms_close.doubleValue) {//当前的开盘小于上一条的收盘,开盘=收盘+最小厚度
                        openPoint.y = closePointY + LABStockLineMinThick;
                    }else {
                        closePointY = openPoint.y + LABStockLineMinThick;
                    }
                }else if (idx+1 < drawLineModels.count) {//idx==0,即第一个
                    id<LABStockDataProtocol> subModel = drawLineModels[idx+1];//后一条数据
                    if (obj.ms_close.doubleValue < subModel.ms_open.doubleValue) {//当前的收盘小于下一条的开盘,开盘=收盘+最小厚度
                        openPoint.y = closePointY + LABStockLineMinThick;
                    }else {
                        closePointY = openPoint.y + LABStockLineMinThick;
                    }
                }else {//都不满足上面的条件,开盘=收盘+最小厚度
                    openPoint.y = closePointY - LABStockLineMinThick;
                }
            }
        }
        CGPoint closePoint = CGPointMake(xPosition, closePointY);
        CGPoint accessory = closePoint;
        ///生成位置数据
        LABStockKLinePositionModel *positionModel = [LABStockKLinePositionModel initWithOpen:openPoint close:closePoint high:highPonit low:lowPoint accessory:accessory];
        [self.drawPositionModels addObject:positionModel];
    }];
    return self.drawPositionModels;
}

///绘制K线
///@param ctx 上下文
///@param rect 绘制的范围
///@param drawLineModels 绘制数据
- (void)drawKLine:(CGContextRef)ctx rect:(CGRect)rect drawLineModels:(NSArray <id<LABStockDataProtocol>>*)drawLineModels {
    [self.drawPositionModels enumerateObjectsUsingBlock:^(LABStockKLinePositionModel *obj, NSUInteger idx, BOOL * stop) {
        id<LABStockDataProtocol> curModel = drawLineModels[idx];
        ///设置线宽
        CGContextSetLineWidth(ctx, [LABStockVariable lineWidth]);
        UIColor *color;
        ///判断涨跌,确定选中的位置,涨,收盘位置,跌,开盘位置
        if (curModel.ms_open.doubleValue < curModel.ms_close.doubleValue) {//开盘<收盘,涨
            color = [UIColor LABStock_increaseColor];
        }else if (curModel.ms_open.doubleValue > curModel.ms_close.doubleValue) {//开盘>收盘,跌
            color = [UIColor LABStock_decreaseColor];
        }else {//开盘等于收盘
            color = [UIColor LABStock_equalColor];
        }
//        id<LABStockDataProtocol> preModel;
//        if (idx>0) {//第一个以后
//            preModel = drawLineModels[idx-1];
//        }else {//idx==0,即第一个
//            if (self.range.location != 0) {//说明不是从0开始
//                preModel = self.lineModels[self.range.location-1];
//            }
//        }
//        if (curModel.ms_close.doubleValue > preModel.ms_close.doubleValue) {//当前的收盘>=前一条的收盘,涨
//            color = [UIColor LABStock_increaseColor];
//        }else if (curModel.ms_close.doubleValue < preModel.ms_close.doubleValue) {
//            color = [UIColor LABStock_decreaseColor];
//        }else {
//            color = [UIColor LABStock_equalColor];
//        }
        ///设置颜色
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        const CGPoint solidPoints[] = {obj.openPoint, obj.closePoint};
        CGContextStrokeLineSegments(ctx, solidPoints, 2);
        CGContextSetLineWidth(ctx, LABStockShadowLineWidth);
        const CGPoint shadowPoints[] = {obj.highPoint, obj.lowPoint};
        CGContextStrokeLineSegments(ctx, shadowPoints, 2);
    }];
}

- (void)drawUSAKLine:(CGContextRef)ctx rect:(CGRect)rect drawLineModels:(NSArray <id<LABStockDataProtocol>>*)drawLineModels {
    [self.drawPositionModels enumerateObjectsUsingBlock:^(LABStockKLinePositionModel *obj, NSUInteger idx, BOOL * stop) {
        id<LABStockDataProtocol> curModel = drawLineModels[idx];
        ///设置线宽
        CGContextSetLineWidth(ctx, LABStockShadowLineWidth);
        UIColor *color;
        ///判断涨跌,确定选中的位置,涨,收盘位置,跌,开盘位置
        if (curModel.ms_open.doubleValue < curModel.ms_close.doubleValue) {//开盘<收盘,涨
            color = [UIColor LABStock_increaseColor];
        }else if (curModel.ms_open.doubleValue > curModel.ms_close.doubleValue) {//开盘>收盘,跌
            color = [UIColor LABStock_decreaseColor];
        }else {//开盘等于收盘
            color = [UIColor LABStock_equalColor];
        }
//        id<LABStockDataProtocol> preModel;
//        if (idx>0) {//第一个以后
//            preModel = drawLineModels[idx-1];
//        }else {//idx==0,即第一个
//            if (self.range.location != 0) {//说明不是从0开始
//                preModel = self.lineModels[self.range.location-1];
//            }
//        }
//        if (curModel.ms_close.doubleValue > preModel.ms_close.doubleValue) {//当前的收盘>前一条的收盘,涨
//            color = [UIColor LABStock_increaseColor];
//        }else if (curModel.ms_close.doubleValue < preModel.ms_close.doubleValue) {
//            color = [UIColor LABStock_decreaseColor];
//        }else {
//            color = [UIColor LABStock_equalColor];
//        }
        ///设置颜色
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        ///影线
        const CGPoint shadowPoints[] = {obj.highPoint, obj.lowPoint};
        CGContextStrokeLineSegments(ctx, shadowPoints, 2);
        
        CGFloat lineWidth = [LABStockVariable lineWidth];
        ///左边开盘
        const CGPoint openPoints[] = {CGPointMake(obj.openPoint.x-lineWidth/2.0, obj.openPoint.y+LABStockShadowLineWidth/4.0), CGPointMake(obj.openPoint.x, obj.openPoint.y+LABStockShadowLineWidth/4.0)};
        CGContextStrokeLineSegments(ctx, openPoints, 2);
        ///右边收盘
        const CGPoint closePoints[] = {CGPointMake(obj.closePoint.x, obj.closePoint.y-LABStockShadowLineWidth/4.0), CGPointMake(obj.closePoint.x+lineWidth/2.0, obj.closePoint.y-LABStockShadowLineWidth/4.0)};
        CGContextStrokeLineSegments(ctx, closePoints, 2);
    }];
}

#pragma mark --懒加载,getter

- (NSMutableArray<LABStockKLinePositionModel *> *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

@end
