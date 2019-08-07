//
//  LABStockKLineBgView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LABStockAccessoryBase;

NS_ASSUME_NONNULL_BEGIN

///K线绘制主页面网格背景,因考虑到背景网格是不会变动的,而网格上面的数值会随着数据变化而变化,所以包含两个页面,一个是网格绘制,一个是数值绘制,
///其中数值绘制还包含分时中指标数据的绘制
@interface LABStockKLineBgView : UIView

///更新选中的模型数组
///@param index 选中模型的索引
///@param maxValue 数据最大值范围
///@param minValue 数据最小值范围
///@param accessory 指标对象
- (void)updateSelectIndex:(CGFloat)index
                 maxValue:(CGFloat)maxValue
                 minValue:(CGFloat)minValue
               accecssory:(LABStockAccessoryBase *)accessory;

@end

NS_ASSUME_NONNULL_END
