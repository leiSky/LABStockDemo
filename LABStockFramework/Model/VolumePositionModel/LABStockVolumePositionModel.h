//
//  LABStockVolumePositionModel.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///成交量柱状图位置坐标模型
@interface LABStockVolumePositionModel : NSObject
///起始点
@property (nonatomic, assign) CGPoint startPoint;
///结束点
@property (nonatomic, assign) CGPoint endPoint;

///初始化方法
///@param startPoint 起始坐标
///@param endPoint 结束坐标
///@return 位置坐标模型LABStockVolumePositionModel对象
+ (instancetype)modelWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
