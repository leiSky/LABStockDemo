//
//  UIColor+LABStock.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///颜色相关类
@interface UIColor (LABStock)

///颜色操作
+ (UIColor *)colorWithHex:(UInt32)hex;
+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a;

///行情部分总的背景色
+ (UIColor *)LABStock_stockBgColor;

///整体背景颜色
+ (UIColor *)LABStock_bgColor;

///K线图背景辅助线颜色
+ (UIColor *)LABStock_bgLineColor;

///主文字颜色
+ (UIColor *)LABStock_textColor;

///选中文字颜色
+ (UIColor *)LABStock_selectedTextColor;

///分时k线选中时的十字指标线的颜色
+ (UIColor *)LABStock_selectedLineColor;

///分时线颜色
+ (UIColor *)LABStock_timeLineColor;

///分时线下方背景阴影颜色
+ (UIColor *)LABStock_timeLineBgColor;

///k线涨的颜色
+ (UIColor *)LABStock_increaseColor;

///k线跌的颜色
+ (UIColor *)LABStock_decreaseColor;

///k线平的颜色
+ (UIColor *)LABStock_equalColor;

///指标涨的颜色
+ (UIColor *)LABStock_accessoryIncreaseColor;

///指标跌的颜色
+ (UIColor *)LABStock_accessoryDecreaseColor;

///指标平的颜色
+ (UIColor *)LABStock_accessoryEqualColor;

///指标的第一种颜色
+ (UIColor *)LABStock_accessoryFirstColor;

///指标的第二种颜色
+ (UIColor *)LABStock_accessorySecondColor;

///指标的第三种颜色
+ (UIColor *)LABStock_accessoryThreeColor;

///指标的第四种颜色
+ (UIColor *)LABStock_accessoryFourColor;

///指标的第五种颜色
+ (UIColor *)LABStock_accessoryFiveColor;

///指标的第六种颜色
+ (UIColor *)LABStock_accessorySixColor;

@end

NS_ASSUME_NONNULL_END
