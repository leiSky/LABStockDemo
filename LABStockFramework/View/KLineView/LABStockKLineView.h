//
//  LABStockKLineView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

@class LABStockKLinePositionModel;
@class LABStockAccessoryBase;

NS_ASSUME_NONNULL_BEGIN

///K线绘制主页面
@interface LABStockKLineView : UIView

///绘制方法
///@param xPosition 绘制开始的x坐标
///@param drawModelsPreModel 屏幕绘制数组第一条数据的前一条数据,用来计算涨跌颜色,可能为nil
///@param drawLineModels 绘制的数据模型数组
///@param maxValue 最大值
///@param minValue 最小值
///@param accessory 指标对象
- (NSArray<LABStockKLinePositionModel *> *)drawViewWithXPosition:(CGFloat)xPosition
                                               drawModelsPreModel:(id<LABStockDataProtocol>)drawModelsPreModel
                                                       drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                                                         maxValue:(CGFloat)maxValue
                                                         minValue:(CGFloat)minValue
                                                       accecssory:(LABStockAccessoryBase *)accessory;

@end

NS_ASSUME_NONNULL_END
