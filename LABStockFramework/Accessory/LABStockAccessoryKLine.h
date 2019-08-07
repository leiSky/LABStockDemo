//
//  LABStockAccessoryKLine.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryBase.h"

NS_ASSUME_NONNULL_BEGIN

///某些指标会用到K线蜡烛图的绘制方法,所以这里把K线蜡烛图绘制当成的指标
@interface LABStockAccessoryKLine : LABStockAccessoryBase

///绘制USA K线
///@param ctx 上下文
///@param rect 绘制的范围
///@param xPosition 起始x坐标
///@param max 数据最大值范围
///@param min 数据最小值范围
- (void)drawUSAGraphWithCtx:(CGContextRef)ctx rect:(CGRect)rect xPosition:(CGFloat)xPosition max:(CGFloat)max min:(CGFloat)min;

@end

NS_ASSUME_NONNULL_END
