//
//  UIColor+LABStock.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "UIColor+LABStock.h"

@implementation UIColor (LABStock)

+ (UIColor *)colorWithHex:(UInt32)hex {
    return [UIColor colorWithHex:hex alpha:1.f];
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a {
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
}

///行情部分总的背景色
+ (UIColor *)LABStock_stockBgColor {
    return [self colorWithR:33.0f g:43.0f b:62.0f a:1.0f];
}

///整体背景颜色
+ (UIColor *)LABStock_bgColor {
    return [self colorWithR:38.0f g:48.0f b:71.0f a:1.0f];
}

///K线图背景辅助线颜色
+ (UIColor *)LABStock_bgLineColor {
    return [self colorWithR:51.0f g:64.0f b:95.0f a:1.0f];
}

///主文字颜色
+ (UIColor *)LABStock_textColor {
    return [self colorWithR:156.0f g:174.0f b:198.0f a:1.0];
}

///选中文字颜色
+ (UIColor *)LABStock_selectedTextColor {
    return [self colorWithR:0.0f g:122.0f b:255.0f a:1.0f];
}

///分时k线选中时的十字指标线的颜色
+ (UIColor *)LABStock_selectedLineColor {
    return [self colorWithHex:0xcccccc];
}

///分时线颜色
+ (UIColor *)LABStock_timeLineColor {
    return [self colorWithHex:0x007aff];
}

///分时线下方背景色
+ (UIColor *)LABStock_timeLineBgColor {
    return [self colorWithR:92.0f g:126.0f b:192.0f a:0.1f];
}

///k线涨的颜色
+ (UIColor *)LABStock_increaseColor {
    return [self colorWithHex:0x2acbb9];
}

///k线跌的颜色
+ (UIColor *)LABStock_decreaseColor {
    return [self colorWithHex:0xfe776b];
}

///k线平的颜色
+ (UIColor *)LABStock_equalColor {
    return [self LABStock_increaseColor];
}

///指标涨的颜色
+ (UIColor *)LABStock_accessoryIncreaseColor {
    return [UIColor colorWithHex:0x3af26a];
}

///指标跌的颜色
+ (UIColor *)LABStock_accessoryDecreaseColor {
    return [UIColor colorWithHex:0xfe295b];
}

///指标平的颜色
+ (UIColor *)LABStock_accessoryEqualColor {
    return [self LABStock_accessoryIncreaseColor];
}

///指标的第一种颜色
+ (UIColor *)LABStock_accessoryFirstColor {
    return [self colorWithHex:0x53c98b];
}

///指标的第二种颜色
+ (UIColor *)LABStock_accessorySecondColor {
    return [self colorWithHex:0xe55143];
}

///指标的第三种颜色
+ (UIColor *)LABStock_accessoryThreeColor {
    return [self colorWithHex:0x7046e5];
}

///指标的第四种颜色
+ (UIColor *)LABStock_accessoryFourColor {
    return [self colorWithHex:0xffffff];
}

///指标的第五种颜色
+ (UIColor *)LABStock_accessoryFiveColor {
    return [self colorWithHex:0xabc4fe];
}

///指标的第六种颜色
+ (UIColor *)LABStock_accessorySixColor {
    return [self colorWithHex:0xdee446];
}

@end
