
//
//  LABStockMaskView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockMaskView.h"
#import "UIColor+LABStock.h"
#import "LABStockTimeUtils.h"
#import "LABStockDataProtocol.h"
#import "LABStockVariable.h"
#import "LABStockFormatUtils.h"

@interface LABStockMaskView ()

///左右间距,值为3
@property (nonatomic, assign) CGFloat gap;
///字体属性
@property (nonatomic, strong) NSDictionary *attribute;

@end

@implementation LABStockMaskView

- (instancetype)init {
    if ([super init]) {
        _gap = 3;
        _attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont+2],NSForegroundColorAttributeName: [UIColor LABStock_selectedLineColor]};
    }
    return self;
}

#pragma mark --绘制

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    ///画十字图
    [self drawCrosslines:ctx];
    ///时间
    [self drawTime:ctx];
    ///横坐标值
    [self drawValue:ctx];
}


- (void)drawCrosslines:(CGContextRef)ctx {
    ///颜色和线宽
    CGContextSetStrokeColorWithColor(ctx, [UIColor LABStock_selectedLineColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    ///横线竖线坐标
    const CGPoint line1[] = {CGPointMake(0, self.point.y), CGPointMake(CGRectGetWidth(self.frame), self.point.y)};
    const CGPoint line2[] = {CGPointMake(self.point.x, 0), CGPointMake(self.point.x ,CGRectGetHeight(self.frame))};
    ///画线
    CGContextStrokeLineSegments(ctx, line1, 2);
    CGContextStrokeLineSegments(ctx, line2, 2);
}

- (void)drawTime:(CGContextRef)ctx {
    NSString *time = [LABStockTimeUtils stringByDateString:self.selectModel.ms_date stockType:self.type];
    CGRect textRect = [LABStockVariable rectOfNSString:time attribute:_attribute];
    CGFloat timeX = self.point.x;
    CGRect timeRect;
    CGRect bgRect;
    CGFloat bgWidth = textRect.size.width+2*_gap;
    CGFloat timeH = LABStockLineDateHigh-0.5;
    CGFloat timeRectY = (timeH-textRect.size.height)/2.0 + self.timeY;
    if (timeX+(textRect.size.width/2.0+_gap) > CGRectGetMaxX(self.frame)) {//最右边
        bgRect = CGRectMake(CGRectGetMaxX(self.frame)-bgWidth, self.timeY, bgWidth, timeH);
        timeRect = CGRectMake(CGRectGetMinX(bgRect)+_gap, timeRectY, textRect.size.width, textRect.size.height);
    }else if (timeX - textRect.size.width/2.0 < 0) {//最左边
        bgRect = CGRectMake(0, self.timeY, bgWidth, timeH);
        timeRect = CGRectMake(_gap, timeRectY, textRect.size.width, textRect.size.height);
    }else {
        bgRect = CGRectMake(timeX-bgWidth/2.0, self.timeY, bgWidth, timeH);
        timeRect = CGRectMake(CGRectGetMinX(bgRect)+_gap, timeRectY, textRect.size.width, textRect.size.height);
    }
    CGContextSetFillColorWithColor(ctx, [UIColor LABStock_stockBgColor].CGColor);
    CGContextFillRect(ctx, bgRect);
    [time drawInRect:timeRect withAttributes:_attribute];
    CGContextAddRect(ctx, bgRect);
    CGContextStrokePath(ctx);
}

- (void)drawValue:(CGContextRef)ctx {
    NSString *value = [LABStockFormatUtils getStringWithDouble:[self.selectModel.ms_close doubleValue] andScale:[LABStockVariable pricePrecision]];
    CGRect textRect = [LABStockVariable rectOfNSString:value attribute:_attribute];
    CGRect valueRect;
    CGRect bgRect;
    CGFloat bgWidth = textRect.size.width+2*_gap;
    CGFloat bgRectH = textRect.size.height+2*_gap;
    CGFloat bgRectY = self.point.y - bgRectH/2.0;
    CGFloat valueRectY = bgRectY + _gap;
    if (self.point.x >= CGRectGetWidth(self.frame)/2.0) {//超过一半,在右边
        bgRect = CGRectMake(CGRectGetMaxX(self.frame)-bgWidth, bgRectY, bgWidth, bgRectH);
        valueRect =CGRectMake(CGRectGetMinX(bgRect)+_gap, valueRectY, textRect.size.width, textRect.size.height);
    }else {//在左边
        bgRect = CGRectMake(0, bgRectY, bgWidth, bgRectH);
        valueRect = CGRectMake(_gap, valueRectY, textRect.size.width, textRect.size.height);
    }
    CGContextSetFillColorWithColor(ctx, [UIColor LABStock_stockBgColor].CGColor);
    CGContextFillRect(ctx, bgRect);
    [value drawInRect:valueRect withAttributes:_attribute];
    CGContextAddRect(ctx, bgRect);
    CGContextStrokePath(ctx);
}

#pragma mark --外部方法

- (void)updateSelectModel:(id<LABStockDataProtocol>)selectModel positionPoint:(CGPoint)point stockTimePositionY:(CGFloat)positionY {
    _selectModel = selectModel;
    _point = point;
    _timeY = positionY;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end
