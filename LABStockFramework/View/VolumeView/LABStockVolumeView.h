//
//  LABStockVolumeView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

@class LABStockAccessoryBase;

NS_ASSUME_NONNULL_BEGIN

///成交量绘制主页面
@interface LABStockVolumeView : UIView

///绘制方法
///@param xPosition 绘制开始的x坐标
///@param drawModelsPreModel 屏幕绘制数组第一条数据的前一条数据,用来计算涨跌颜色,可能为nil
///@param drawLineModels 绘制的数据模型数组
///@param maxValue 最大值
///@param accessory 指标对象
- (void)drawViewWithXPosition:(CGFloat)xPosition
           drawModelsPreModel:(id<LABStockDataProtocol>)drawModelsPreModel
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                     maxValue:(CGFloat)maxValue
                   accecssory:(LABStockAccessoryBase *)accessory;

@end

NS_ASSUME_NONNULL_END
