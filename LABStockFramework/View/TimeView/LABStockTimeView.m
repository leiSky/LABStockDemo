//
//  LABStockTimeView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeView.h"
#import "LABStockDataProtocol.h"
#import "LABStockVariable.h"
#import "LABStockTimeUtils.h"
#import "UIColor+LABStock.h"

@interface LABStockTimeView ()

@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
@property (nonatomic, strong) NSArray<NSValue *> *drawPositions;
@property (nonatomic, assign) LABStockType type;

@end

@implementation LABStockTimeView

#pragma mark --初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

#pragma mark --绘制

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.drawLineModels || self.drawLineModels.count <= 0) {
        return;
    }
    
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    NSInteger screenCount = CGRectGetWidth(self.frame)/(lineGap+lineWidth);
    
    NSMutableArray<NSValue *> *tmpDrawPositions = [NSMutableArray arrayWithArray:self.drawPositions];
    ///若数据条数不等于整个屏幕显示的数量条数，就要补齐，是为了让绘制坐标补齐
    CGPoint lastDrawPosition = tmpDrawPositions.lastObject.CGPointValue;
    for (NSInteger i=tmpDrawPositions.count; i<screenCount; i++) {
        CGPoint nextPoint = CGPointMake(lastDrawPosition.x+(lineGap+lineWidth), 0);
        NSValue *nextValue = [NSValue valueWithCGPoint:nextPoint];
        [tmpDrawPositions addObject:nextValue];
        lastDrawPosition = nextPoint;
    }
    
    NSMutableArray<NSString *> *drawTimes = [NSMutableArray array];
    for (id<LABStockDataProtocol> model in self.drawLineModels) {
        [drawTimes addObject:model.ms_date];
    }
    ///若数据条数不等于整个屏幕显示的数量条数，就要补齐，是为了让时间补齐
    NSString *lastTime = drawTimes.lastObject;
    for (NSInteger i=drawTimes.count; i<screenCount; i++) {
        NSDate *date = [LABStockTimeUtils getDateFromString:lastTime type:LABStockTimeStyle_YYYYMMDDHHMMSS];
        NSDate *nextDate = [date dateByAddingTimeInterval:[self getSepartTimeByType:self.type]];
        NSString *nextDateStr = [LABStockTimeUtils getStringFromDate:nextDate type:LABStockTimeStyle_YYYYMMDDHHMMSS];
        [drawTimes addObject:nextDateStr];
        lastTime = nextDateStr;
    }
    
    NSInteger row = 5;
    NSMutableArray *xPositions = [NSMutableArray array];
    CGFloat x_unit = self.frame.size.width / (row - 1);
    for (int i=1; i<=row-2; i++) {
        CGFloat x = i*x_unit;
        [xPositions addObject:@(x)];
    }
    
    __block NSMutableArray<NSString *> *times = [NSMutableArray array];
    [times addObject:drawTimes.firstObject];
    
    for (NSNumber *x_num in xPositions) {
        CGFloat x = [x_num doubleValue];
        [tmpDrawPositions enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
            CGFloat drawX = [obj CGPointValue].x;
            CGFloat drawMinX = drawX - (lineWidth+lineGap)/2.0;
            CGFloat drawMaxX = drawX + (lineWidth+lineGap)/2.0;
            if (x >= drawMinX && x < drawMaxX) {
                [times addObject:drawTimes[idx]];
                *stop = YES;
            }
        }];
    }
    [times addObject:drawTimes.lastObject];
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:LABStockAccessoryFont],NSForegroundColorAttributeName:[UIColor LABStock_textColor]};
    [times enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *text = [LABStockTimeUtils stringByDateString:obj stockType:self.type];
        CGSize size = [LABStockVariable rectOfNSString:text attribute:attribute].size;
        CGFloat y = (CGRectGetHeight(self.frame)-size.height)/2.0;
        if (idx == 0) {//第一个,靠左
            [text drawAtPoint:CGPointMake(0, y) withAttributes:attribute];
        }else if (idx == times.count-1) {//最后一个,靠右
            [text drawAtPoint:CGPointMake(CGRectGetWidth(self.frame)-size.width, y) withAttributes:attribute];
        }else {//居中
            CGFloat x = [xPositions[idx-1] doubleValue];
            [text drawAtPoint:CGPointMake(x-size.width/2.0, y) withAttributes:attribute];
        }
    }];
}

///根据分时k线k类型获取时间间隔
///@param type 分时K线类型
///@return 时间间隔
- (NSTimeInterval)getSepartTimeByType:(LABStockType)type {
    NSTimeInterval time = 60;
    switch (type) {
        case LABStockTypeTimeLine:
        case LABStockTypeKLine1Min:
            break;
        case LABStockTypeKLine5Min:
            time = 5*60;
            break;
        case LABStockTypeKLine15Min:
            time = 15*60;
            break;
        case LABStockTypeKLine30Min:
            time = 30*60;
            break;
        case LABStockTypeKLine1Hour:
            time = 1*60*60;
            break;
        case LABStockTypeKLine4Hour:
            time = 4*60*60;
            break;
        case LABStockTypeKLineDay:
            time = 24*60*60;
            break;
        case LABStockTypeKLineWeek:
            time = 7*24*60*60;
            break;
        case LABStockTypeKLineMonth:
            time = 30*24*60*60;
            break;
    }
    return time;
}

#pragma mark --外部方法

- (void)drawViewWithDrawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels drawPositions:(NSArray<NSValue *> *)drawPositions stockType:(LABStockType)type {
    self.drawLineModels = drawLineModels;
    self.drawPositions = drawPositions;
    self.type = type;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end
