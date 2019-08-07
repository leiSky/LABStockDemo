//
//  LABStockKLineMaskView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockKLineMaskView.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"

@implementation LABStockKLineMaskView

- (void)drawCrosslines:(CGContextRef)ctx {
    ///竖线
    CGContextSetStrokeColorWithColor(ctx, [[UIColor LABStock_selectedLineColor] colorWithAlphaComponent:0.2].CGColor);
    CGContextSetLineWidth(ctx, [LABStockVariable lineWidth]);
    const CGPoint line2[] = {CGPointMake(self.point.x, 0), CGPointMake(self.point.x ,CGRectGetHeight(self.frame))};
    CGContextStrokeLineSegments(ctx, line2, 2);
    ///横线
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_selectedLineColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    const CGPoint line1[] = {CGPointMake(0, self.point.y), CGPointMake(CGRectGetWidth(self.frame), self.point.y)};
    CGContextStrokeLineSegments(ctx, line1, 2);
}

@end
