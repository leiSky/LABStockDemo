//
//  LABStockVariable.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LABStockConstant.h"

NS_ASSUME_NONNULL_BEGIN

///变量相关类
@interface LABStockVariable : NSObject

///图中蜡烛的宽度
+ (CGFloat)lineWidth;

///设置图中蜡烛的宽度
///@param lineWidth 宽度
+ (void)setLineWith:(CGFloat)lineWidth;

///蜡烛间隔，初始值为1
+ (CGFloat)lineGap;

///设置图中蜡烛的间距
///@param lineGap 间距
+ (void)setLineGap:(CGFloat)lineGap;

///成交量和副图的高度比例,默认0.2
+ (CGFloat)volumeViewHeighRatio;

///当前显示的分时k线类型
+ (LABStockType)curStockType;

///设置当前显示的分时k线类型
///@param type 分时k线类型
+ (void)setCurStockType:(LABStockType)type;

///当前显示的副图类型
+ (LABAccessoryType)curStockAccessoryType;

///设置当前显示的副图类型
///@param type 副图类型
+ (void)setCurStockAccessoryType:(LABAccessoryType)type;

///价格的精度
+ (int)pricePrecision;

///设置价格的精度
///@param pricePrecision 精度
+ (void)setPricePrecision:(int)pricePrecision;

///数量的精度
+ (int)volumePrecision;

///数量的精度
///@param volumePrecision 精度
+ (void)setVolumePrecision:(int)volumePrecision;

///计算字符串的范围
///@param string 要计算的字符串
///@param attribute 相关参数
///@return 范围
+ (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute;

@end

NS_ASSUME_NONNULL_END
