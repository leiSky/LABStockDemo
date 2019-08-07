//
//  LABStockAccessoryBase.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

///指标父类,提供基础属性和方法
@interface LABStockAccessoryBase : NSObject

///指标名,每种指标对应自己的名字
@property (nonatomic, copy) NSString *accessoryName;

///保留小数位数,为0时显示整数，为2时保留2位小数，为3时保留3位小数,默认为2
@property (nonatomic, assign) int precision;

///所有的数据,用来计算各种坐标,若只用绘制的数据,则开头计算出的数据会有问题
@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *lineModels;

///绘制的数据在总数据中的范围
@property (nonatomic, assign) NSRange range;

///绘制的数据最大值,计算各指标数据的位置,默认为-MAXFLOAT
@property (nonatomic, assign) CGFloat maxValue;

///绘制的数据最小值,计算各指标数据的位置,默认为MAXFLOAT
@property (nonatomic, assign) CGFloat minValue;

///计算结果数组
@property (nonatomic, strong) NSMutableArray *m_data;

///指标绘制Y坐标的最小最大范围
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CGFloat minY;

#pragma mark --子类需要实现的父类方法

///初始化方法,子类实现需要调用父类
///@param lineModels 所有的数据
- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels NS_REQUIRES_SUPER;

///计算一定范围内的最大最小值
///@param range 计算的范围
- (void)getMaxMin:(NSRange)range;

///绘制指标图形
///@praam ctx 上下文
///@param rect 绘制的范围
///@param xPosition 开始的x坐标
///@param max 最大值范围
///@param min 最小值范围
- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min;

///绘制指标数值
///@param ctx 上下文
///@param rect 绘制的范围
///@param index 更新指标数据的索引,从计算的数据中取
- (void)drawGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect selectIndex:(NSInteger)index;

#pragma mark --为子类提供的计算和绘图方法

///计算最大最小值
///@param data 需要计算的数据
///@param iFirst 第一个有意义数据的位置
///@param range 计算数据的范围
- (void)getValueMaxMin:(NSArray<NSNumber *> *)data iFirst:(NSInteger)iFirst range:(NSRange)range;

///求行情收盘价的平均值
///@param dayCount 周期天数
///@param dataArray 计算的数据
- (void)averageClose:(NSInteger)dayCount dataArray:(NSMutableArray<NSNumber *> *)dataArray;

///求计算数据的平均值
///@param begin 开始计算的位置
///@param count 长度
///@param dayCount 周期天数
///@param source 原数据
///@param destination 目标数据
- (void)averageData:(NSInteger)begin
              count:(NSInteger)count
           dayCount:(NSInteger)dayCount
             source:(NSArray<NSNumber *> *)source
        destination:(NSMutableArray<NSNumber *> *)destination;

///画线
///@param ctx 上下文
///@param rect 绘制的范围
///@param xPosition 绘制x的起始坐标
///@param max 数据最大范围
///@param min 数据最小范围
///@param data 数据数组
///@param iFirst 第一个有意义数据的位置
///@param color 线的颜色
- (void)drawLineWithCtx:(CGContextRef)ctx
                   rect:(CGRect)rect
              xPosition:(CGFloat)xPosition
                    max:(CGFloat)max
                    min:(CGFloat)min
                   data:(NSArray<NSNumber *> *)data
                 iFirst:(NSInteger)iFirst
                  color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
