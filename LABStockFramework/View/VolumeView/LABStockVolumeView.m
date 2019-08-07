//
//  LABStockVolumeView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVolumeView.h"
#import "LABStockDataProtocol.h"
#import "LABStockVolumePositionModel.h"
#import "LABStockAccessoryBase.h"
#import "LABStockVariable.h"
#import "LABStockConstant.h"
#import "UIColor+LABStock.h"

@interface LABStockVolumeView ()

@property (nonatomic, strong) id<LABStockDataProtocol>drawModelsPreModel;
@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
@property (nonatomic, strong) NSMutableArray<LABStockVolumePositionModel *> *drawPositionModels;
@property (nonatomic, strong) LABStockAccessoryBase *accessory;
@property (nonatomic, assign) CGFloat xPosition;
@property (nonatomic, assign) CGFloat maxValue;

@end

@implementation LABStockVolumeView

#pragma mark --绘制

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.drawPositionModels) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.drawPositionModels.count > 0) {
        [self drawVolume:ctx];
    }
    if (self.accessory) {
        self.accessory.minY = LABStockLineVolumeViewMinY;
        self.accessory.maxY = CGRectGetHeight(rect);
        [self.accessory drawGraphWithCtx:ctx rect:rect xPosition:self.xPosition max:self.maxValue min:0];
    }
}

#pragma mark --外部方法

- (void)drawViewWithXPosition:(CGFloat)xPosition
           drawModelsPreModel:(id<LABStockDataProtocol>)drawModelsPreModel
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                     maxValue:(CGFloat)maxValue
                   accecssory:(LABStockAccessoryBase *)accessory {
    self.xPosition = xPosition;
    self.drawModelsPreModel = drawModelsPreModel;
    self.drawLineModels = drawLineModels;
    self.maxValue = maxValue;
    self.accessory = accessory;
    ///转换为实际坐标
    [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels maxValue:maxValue];
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

#pragma mark--内部方法

///将数据转换为坐标
///@param startX 起始x坐标
///@param drawLineModels 绘制的数据
///@param maxValue 最大值范围
- (void)convertToPositionModelsWithXPosition:(CGFloat)startX
                              drawLineModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                    maxValue:(CGFloat)maxValue {
    if (!drawLineModels) {
        return ;
    }
    _drawLineModels = drawLineModels;
    [self.drawPositionModels removeAllObjects];
    
    CGFloat minY = LABStockLineVolumeViewMinY;
    CGFloat maxY = CGRectGetHeight(self.frame);
    
    CGFloat unitValue = maxValue/(maxY - minY);
    if (unitValue == 0) {
        unitValue = 0.01f;
    }
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    [drawLineModels enumerateObjectsUsingBlock:^(id<LABStockDataProtocol> obj, NSUInteger idx, BOOL * stop) {
        CGFloat xPosition = startX + idx * (lineGap + lineWidth);
        
        CGPoint startPoint = CGPointMake(xPosition, ABS(maxY - obj.ms_volume/unitValue));
        CGPoint endPoint = CGPointMake(xPosition, maxY);
        LABStockVolumePositionModel *model = [LABStockVolumePositionModel modelWithStartPoint:startPoint endPoint:endPoint];
        [self.drawPositionModels addObject:model];
    }];
}

- (void)drawVolume:(CGContextRef)ctx {
    [self.drawPositionModels enumerateObjectsUsingBlock:^(LABStockVolumePositionModel *obj, NSUInteger idx, BOOL *stop) {
        id<LABStockDataProtocol> curModel = self.drawLineModels[idx];
        ///判断蜡烛的颜色
        UIColor *strokeColor;
        if (curModel.ms_open.doubleValue < curModel.ms_close.doubleValue) {//开盘<收盘,涨
            strokeColor = [UIColor LABStock_increaseColor];
        }else if (curModel.ms_open.doubleValue > curModel.ms_close.doubleValue) {//开盘>收盘,跌
            strokeColor = [UIColor LABStock_decreaseColor];
        }else {//开盘等于收盘
            strokeColor = [UIColor LABStock_equalColor];
        }
//        id<LABStockDataProtocol> preModel;
//        if (idx>0) {//第一个以后
//            preModel = self.drawLineModels[idx-1];
//        }else {//idx==0,即第一个
//            preModel = self.drawModelsPreModel;
//        }
//        if (curModel.ms_close.doubleValue > preModel.ms_close.doubleValue) {//当前的收盘>前一条的收盘,涨
//            strokeColor = [UIColor LABStock_increaseColor];
//        }else if (curModel.ms_close.doubleValue < preModel.ms_close.doubleValue) {
//            strokeColor = [UIColor LABStock_decreaseColor];
//        }else {
//            strokeColor = [UIColor LABStock_equalColor];
//        }
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
        CGContextSetLineWidth(ctx, [LABStockVariable lineWidth]);
        const CGPoint solidPoints[] = {obj.startPoint, obj.endPoint};
        CGContextStrokeLineSegments(ctx, solidPoints, 2);
    }];
}

#pragma mark --懒加载,getter

- (NSMutableArray<LABStockVolumePositionModel *> *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

@end
