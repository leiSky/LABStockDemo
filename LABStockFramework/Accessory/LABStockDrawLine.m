//
//  LABStockDrawLine.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockDrawLine.h"
#import "LABStockConstant.h"

@interface LABStockDrawLine ()

@property (nonatomic, assign) CGContextRef context;
@property (nonatomic, strong) NSArray<NSValue *> *positions;
@property (nonatomic, strong) UIColor *lineColor;

@end

@implementation LABStockDrawLine

#pragma mark --初始化

- (instancetype)initWithContext:(CGContextRef)context {
    if ([super init]) {
        self.context = context;
    }
    return self;
}

#pragma mark -- 外部方法

- (void)drawWithColor:(UIColor *)lineColor positions:(NSArray<NSValue *> *)positions {
    self.positions = positions;
    self.lineColor = lineColor;
    if (!self.context || !self.positions || self.positions.count <= 0) {
        return;
    }
    ///设置线宽
    CGContextSetLineWidth(self.context, LABStockAccessoryLineWidth);
    ///设置颜色
    CGContextSetStrokeColorWithColor(self.context, self.lineColor.CGColor);
    ///开始绘制
    CGPoint firstPoint = [self.positions.firstObject CGPointValue];
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    [self.positions enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {//从1开始,第0个已经在上面了
            CGPoint point = [obj CGPointValue];
            CGContextAddLineToPoint(self.context, point.x, point.y);
        }
    }];
    CGContextStrokePath(self.context);
}

@end
