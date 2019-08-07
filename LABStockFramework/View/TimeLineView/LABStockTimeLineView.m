//
//  LABStockTimeLineView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeLineView.h"
#import "LABStockDataProtocol.h"
#import "LABStockAccessoryBase.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"
#import "UIColor+LABStock.h"

@interface LABStockTimeLineView ()

@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
@property (nonatomic, strong) NSMutableArray<NSValue *> *drawPositionModels;
@property (nonatomic, strong) LABStockAccessoryBase *accessory;
@property (nonatomic, assign) CGFloat xPosition;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

@end

@implementation LABStockTimeLineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.drawPositionModels) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.drawPositionModels.count > 0) {
        [self drawTimeLine:ctx];
    }
    if (self.accessory) {
        self.accessory.minY = LABStockLineMainViewMinY;
        self.accessory.maxY = CGRectGetHeight(rect) - LABStockLineMainViewMinY;
        [self.accessory drawGraphWithCtx:ctx rect:rect xPosition:self.xPosition max:self.maxValue min:self.minValue];
    }
}

#pragma mark --外部方法

- (NSArray<NSValue *> *)drawViewWithXPosition:(CGFloat)xPosition
                                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                     maxValue:(CGFloat)maxValue
                                     minValue:(CGFloat)minValue
                                   accecssory:(LABStockAccessoryBase *)accessory {
    ///保存数据
    self.xPosition = xPosition;
    self.maxValue = maxValue;
    self.minValue = minValue;
    self.accessory = accessory;
    ///计算位置
    NSArray<NSValue *> *tmpArray = [self convertToPositionModelsWithXPosition:xPosition drawLineModels:drawLineModels maxValue:maxValue minValue:minValue];
    ///刷新
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
    
    return tmpArray;
}

#pragma mark --内部方法

///将数据转换为坐标
///
///返回的坐标数组只包含显示数据对应的坐标,而内部保存的drawPositionModels则包含上/下一条(若存在的话)
///@param startX 起始x坐标
///@param drawLineModels 绘制的数据
///@param maxValue 最大值范围
///@param minValue 最小值范围
///@return 坐标数组
- (NSArray<NSValue *> *)convertToPositionModelsWithXPosition:(CGFloat)startX
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
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    ///第一条数据前面还有数据
    id<LABStockDataProtocol> model = [self.drawLineModels firstObject];
    if (model.preModel) {
        CGFloat xPosition = startX - (lineGap + lineWidth);
        CGPoint pricePoint = CGPointMake(xPosition, (maxY - (model.preModel.ms_close.doubleValue - minValue)/unitValue));
        if (pricePoint.y > maxY) {
            pricePoint.y = maxY;
        }
        [self.drawPositionModels addObject:[NSValue valueWithCGPoint:pricePoint]];
    }
    [drawLineModels enumerateObjectsUsingBlock:^(id<LABStockDataProtocol> obj, NSUInteger idx, BOOL *stop) {
        CGFloat xPosition = startX + idx * (lineGap + lineWidth);
        CGPoint pricePoint = CGPointMake(xPosition, (maxY - (obj.ms_close.doubleValue - minValue)/unitValue));
        [self.drawPositionModels addObject:[NSValue valueWithCGPoint:pricePoint]];
        [tmpArray addObject:[NSValue valueWithCGPoint:pricePoint]];
    }];
    ///最后一条后面还有数据
    model = [drawLineModels lastObject];
    if (model.nextModel) {
        CGFloat xPosition = startX + drawLineModels.count * (lineGap + lineWidth);
        CGPoint pricePoint = CGPointMake(xPosition, (maxY - (model.nextModel.ms_close.doubleValue - minValue)/unitValue));
        if (pricePoint.y > maxY) {
            pricePoint.y = maxY;
        }
        [self.drawPositionModels addObject:[NSValue valueWithCGPoint:pricePoint]];
    }
    return [tmpArray copy];
}

///绘制分时线,并绘制分时线下面的阴影
///@param ctx 上下文
- (void)drawTimeLine:(CGContextRef)ctx {
    ///设置线宽
    CGContextSetLineWidth(ctx, LABStockTimeLineWidth);
    ///设置颜色
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_timeLineColor].CGColor);
    ///开始绘制
    [self.drawPositionModels enumerateObjectsUsingBlock:^(NSValue * obj, NSUInteger idx, BOOL *stop) {
        CGPoint point = [obj CGPointValue];
        if (idx == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        }else {
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }];
    CGContextStrokePath(ctx);
    
    CGPoint firstPoint = [self.drawPositionModels.firstObject CGPointValue];
    CGPoint lastPoint = [self.drawPositionModels.lastObject CGPointValue];
    ///创建CGMutablePathRef
    CGMutablePathRef path = CGPathCreateMutable();
    ///绘制Path
    [self.drawPositionModels enumerateObjectsUsingBlock:^(NSValue * obj, NSUInteger idx, BOOL *stop) {
        CGPoint point = [obj CGPointValue];
        if (idx == 0) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
        }else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
    }];
    CGPathAddLineToPoint(path, NULL, lastPoint.x, CGRectGetMaxY(self.frame));
    CGPathAddLineToPoint(path, NULL, firstPoint.x, CGRectGetMaxY(self.frame));
    CGPathCloseSubpath(path);
    //绘制渐变
    [self drawLinearGradient:ctx path:path startColor:[[UIColor LABStock_timeLineColor] colorWithAlphaComponent:0.5].CGColor endColor:[UIColor clearColor].CGColor];
    //释放CGMutablePathRef
    CGPathRelease(path);
}

///渐变色绘制,方向从上到下
///@param ctx 上下文
///@param path 绘制的路径
///@param startColor 起始颜色
///@param endColor 结束颜色
- (void)drawLinearGradient:(CGContextRef)ctx
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark --懒加载

- (NSMutableArray<NSValue *> *)drawPositionModels {
    if (!_drawPositionModels) {
        _drawPositionModels = [NSMutableArray array];
    }
    return _drawPositionModels;
}

@end
