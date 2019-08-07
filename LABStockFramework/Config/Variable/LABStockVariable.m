//
//  LABStockVariable.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVariable.h"

///图中蜡烛的宽度
static CGFloat LABStockLineWidth = 8;
///图中蜡烛的间隔，初始值为1
static CGFloat LABStockLineGap = 1;
///成交量副图高度比例
static CGFloat LABStockVolumeViewHeighRatio = 0.2;
///默认价格精度2
static int LABStockPricePrecision = 2;
///默认数量精度2
static int LABStockVolumePrecision = 2;
///分时k线类型
static LABStockType LAB_StockType = LABStockTypeTimeLine;
///副图类型
static LABAccessoryType LAB_AccessoryType = LABAccessoryTypeMACD;

@implementation LABStockVariable

///图中蜡烛的宽度
+ (CGFloat)lineWidth {
    return LABStockLineWidth;
}

///设置图中蜡烛的宽度
+ (void)setLineWith:(CGFloat)lineWidth {
    if (lineWidth > LABStockLineMaxWidth) {
        lineWidth = LABStockLineMaxWidth;
    }else if (lineWidth < LABStockLineMinWidth) {
        lineWidth = LABStockLineMinWidth;
    }
    LABStockLineWidth = lineWidth;
}

///蜡烛间隔，初始值为1
+ (CGFloat)lineGap {
    return LABStockLineGap;
}

///设置图中蜡烛的间距
+ (void)setLineGap:(CGFloat)lineGap {
    LABStockLineGap = lineGap;
}

///成交量和副图的高度比例
+ (CGFloat)volumeViewHeighRatio {
    return LABStockVolumeViewHeighRatio;
}

///当前显示的分时k线类型
+ (LABStockType)curStockType {
    return LAB_StockType;
}

///设置当前显示的分时k线类型
+ (void)setCurStockType:(LABStockType)type {
    LAB_StockType = type;
}

///当前显示的副图类型
+ (LABAccessoryType)curStockAccessoryType {
    return LAB_AccessoryType;
}

///设置当前显示的副图类型
+ (void)setCurStockAccessoryType:(LABAccessoryType)type {
    LAB_AccessoryType = type;
}

///价格的精度
+ (int)pricePrecision {
    return LABStockPricePrecision;
}

///设置价格的精度
+ (void)setPricePrecision:(int)pricePrecision {
    LABStockPricePrecision = pricePrecision;
}

///数量的精度
+ (int)volumePrecision {
    return LABStockVolumePrecision;
}

///设置数量的精度
+ (void)setVolumePrecision:(int)volumePrecision {
    LABStockVolumePrecision = volumePrecision;
}

///计算字符串的范围
+ (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}

@end
