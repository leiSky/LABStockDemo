//
//  LABStockKLineView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockKLineView.h"
#import "LABStockDataProtocol.h"
#import "LABStockKLinePositionModel.h"
#import "LABStockAccessoryBase.h"
#import "LABStockVariable.h"
#import "UIColor+LABStock.h"
#import "LABStockFormatUtils.h"

@interface LABStockKLineView ()

@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
@property (nonatomic, strong) NSMutableArray<LABStockKLinePositionModel *> *drawPositionModels;
@property (nonatomic, strong) id<LABStockDataProtocol>drawModelsPreModel;
@property (nonatomic, strong) LABStockAccessoryBase *accessory;
@property (nonatomic, assign) CGFloat xPosition;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

@end

@implementation LABStockKLineView

#pragma mark --绘制方法

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [super drawRect:rect];
    if (!self.drawPositionModels) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.drawPositionModels.count > 0) {
        [self drawKLine:ctx];
    }
    if (self.accessory) {
        self.accessory.minY = LABStockLineMainViewMinY;
        self.accessory.maxY = CGRectGetHeight(rect) - LABStockLineMainViewMinY;
        [self.accessory drawGraphWithCtx:ctx rect:rect xPosition:self.xPosition max:self.maxValue min:self.minValue];
    }
}

#pragma mark --外部方法

- (NSArray<LABStockKLinePositionModel *> *)drawViewWithXPosition:(CGFloat)xPosition
                                              drawModelsPreModel:(id<LABStockDataProtocol>)drawModelsPreModel
                                                      drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                                        maxValue:(CGFloat)maxValue
                                                        minValue:(CGFloat)minValue
                                                      accecssory:(LABStockAccessoryBase *)accessory {
    ///保存数据
    self.xPosition = xPosition;
    self.drawModelsPreModel = drawModelsPreModel;
    self.drawLineModels = drawLineModels;
    self.maxValue = maxValue;
    self.minValue = minValue;
    self.accessory = accessory;
    //计算数据
    NSArray<LABStockKLinePositionModel *> *tmpArray = [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels maxValue:maxValue minValue:minValue];
    ///刷新
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
    return tmpArray;
}

#pragma mark --内部方法

- (NSArray<LABStockKLinePositionModel *> *)convertToPositionModelsWithXPosition:(CGFloat)startX
                                                                 drawLineModels:(NSArray <id<LABStockDataProtocol>>*)drawLineModels
                                                                       maxValue:(CGFloat)maxValue
                                                                       minValue:(CGFloat)minValue {
    if (!drawLineModels) {
        return nil;
    }
    _drawLineModels = drawLineModels;
    [self.drawPositionModels removeAllObjects];
    CGFloat minY = LABStockLineMainViewMinY;
    CGFloat maxY = CGRectGetHeight(self.frame) - LABStockLineMainViewMinY;
    CGFloat unitValue = (maxValue - minValue)/(maxY - minY);
    if (unitValue == 0) {
        unitValue = 0.01f;
    }
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    [self.drawLineModels enumerateObjectsUsingBlock:^(id<LABStockDataProtocol> obj, NSUInteger idx, BOOL *stop) {
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

///绘制K线数据
///@param ctx 上下文
- (void)drawKLine:(CGContextRef)ctx {
    LABStockKLinePositionModel *firstPosition = self.drawPositionModels.firstObject;
    id<LABStockDataProtocol> firstModel = self.drawLineModels.firstObject;
    
    ///零时保存记录,用于绘制K线的最高最低的值和坐标
    __block CGPoint highPoint = firstPosition.highPoint;
    __block CGFloat high = firstModel.ms_high.doubleValue;
    __block CGPoint lowPoint = firstPosition.lowPoint;
    __block CGFloat low = firstModel.ms_low.doubleValue;
    
    [self.drawPositionModels enumerateObjectsUsingBlock:^(LABStockKLinePositionModel *obj, NSUInteger idx, BOOL * stop) {
        id<LABStockDataProtocol> curModel = self.drawLineModels[idx];
        ///查找最高最低的点
        if (highPoint.y > obj.highPoint.y) {
            highPoint = obj.highPoint;
            high = curModel.ms_high.doubleValue;
        }
        if (lowPoint.y < obj.lowPoint.y) {
            lowPoint = obj.lowPoint;
            low = curModel.ms_low.doubleValue;
        }
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
//            preModel = self.drawLineModels[idx-1];
//        }else {//idx==0,即第一个
//            preModel = self.drawModelsPreModel;
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
        const CGPoint solidPoints[] = {obj.openPoint, obj.closePoint};
        CGContextStrokeLineSegments(ctx, solidPoints, 2);
        CGContextSetLineWidth(ctx, LABStockShadowLineWidth);
        const CGPoint shadowPoints[] = {obj.highPoint, obj.lowPoint};
        CGContextStrokeLineSegments(ctx, shadowPoints, 2);
    }];
    ///绘制最高最低
    CGFloat showWidth = CGRectGetWidth(self.frame);
    if (highPoint.x > showWidth/2.0) {//左边
        [self drawPrice:high point:highPoint leftOrRight:YES];
    }else {
        [self drawPrice:high point:highPoint leftOrRight:NO];
    }
    if (lowPoint.x > showWidth/2.0) {//左边
        [self drawPrice:low point:lowPoint leftOrRight:YES];
    }else {
        [self drawPrice:low point:lowPoint leftOrRight:NO];
    }
}

///绘制价格显示
///@param price 价格
///@param point 绘制的点
///@param flag 表示绘制的方向 YES 点左边 NO 点右边
- (void)drawPrice:(CGFloat)price point:(CGPoint)point leftOrRight:(BOOL)flag {
    NSString *drawText;
    CGPoint drawPoint;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont+2],NSForegroundColorAttributeName:[UIColor whiteColor]};
    int pricePrecision = [LABStockVariable pricePrecision];
    if (flag) {
        drawText = [NSString stringWithFormat:@"%@—", [LABStockFormatUtils getStringWithDouble:price andScale:pricePrecision]];
        CGSize size = [LABStockVariable rectOfNSString:drawText attribute:attribute].size;
        drawPoint = CGPointMake(point.x-size.width, point.y-size.height/2.0-LABStockShadowLineWidth/2.0);
    }else {
        drawText = [NSString stringWithFormat:@"—%@", [LABStockFormatUtils getStringWithDouble:price andScale:pricePrecision]];
        CGSize size = [LABStockVariable rectOfNSString:drawText attribute:attribute].size;
        drawPoint = CGPointMake(point.x, point.y-size.height/2.0-LABStockShadowLineWidth/2.0);
    }
    [drawText drawAtPoint:drawPoint withAttributes:attribute];
}

#pragma mark --懒加载,getter

- (NSMutableArray<LABStockKLinePositionModel *> *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

@end
