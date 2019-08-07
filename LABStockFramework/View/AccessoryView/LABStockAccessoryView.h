//
//  LABStockAccessoryView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

@class LABStockAccessoryBase;

NS_ASSUME_NONNULL_BEGIN

///指标绘制View
@interface LABStockAccessoryView : UIView

///绘制方法
///@param xPosition 绘制开始的x坐标
///@param drawLineModels 绘制的数据模型数组
///@param maxValue 最大值
///@param minValue 最小值
///@param accessory 指标对象
- (void)drawViewWithXPosition:(CGFloat)xPosition
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                     maxValue:(CGFloat)maxValue
                     minValue:(CGFloat)minValue
                   accecssory:(LABStockAccessoryBase *)accessory;

@end

NS_ASSUME_NONNULL_END
