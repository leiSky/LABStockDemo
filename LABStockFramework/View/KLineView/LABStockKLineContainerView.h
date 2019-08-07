//
//  LABStockKLineContainerView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

@class LABStockKLinePositionModel;

NS_ASSUME_NONNULL_BEGIN

///绘制K线容器View,包含背景和绘制View
@interface LABStockKLineContainerView : UIView

///绘制方法
///@param xPosition 绘制开始的x坐标
///@param lineModels 所有的数据模型数组
///@param drawLineModels 绘制的数据模型数组
///@param range 绘制的数据模型范围
///@param index 在所有数据选中的索引
///@return 计算好位置的数组
- (NSArray<LABStockKLinePositionModel *> *)drawViewWithXPosition:(CGFloat)xPosition
                                                      lineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels
                                                      drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                                       drawRange:(NSRange)range
                                                     selectIndex:(NSInteger)index;

///更新选中的模型数组
///@param index 对应选中数据的索引
- (void)updateSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
