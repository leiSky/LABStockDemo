//
//  LABStockKLinePositionModel.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///k线蜡烛图位置坐标模型
@interface LABStockKLinePositionModel : NSObject
///开盘点
@property (nonatomic, assign) CGPoint openPoint;
///收盘点
@property (nonatomic, assign) CGPoint closePoint;
///最高点
@property (nonatomic, assign) CGPoint highPoint;
///最高点
@property (nonatomic, assign) CGPoint lowPoint;
///十字坐标的点
@property (nonatomic, assign) CGPoint accessoryPoint;

///初始化方法
///@param open 开盘坐标
///@param close 收盘坐标
///@param high 最高坐标
///@param low 最低坐标
///@param accessory 十字坐标
///@return 位置坐标模型LABStockKLinePositionModel对象
+ (instancetype)initWithOpen:(CGPoint)open close:(CGPoint)close high:(CGPoint)high low:(CGPoint)low accessory:(CGPoint)accessory;

@end

NS_ASSUME_NONNULL_END
