//
//  LABStockAccessoryBgView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LABStockAccessoryBase;

NS_ASSUME_NONNULL_BEGIN

///指标网格背景,因考虑到背景网格是不会变动的,而网格上面的数值会随着数据变化而变化,所以包含两个页面,一个是网格绘制,一个是数值绘制,
///其中数值绘制还包含分时中指标数据的绘制
@interface LABStockAccessoryBgView : UIView

///更新选中的模型数组
///@param index 选中模型的索引
///@param maxValue 用来计算网格数据显示
///@param minValue 用来计算网格数据显示
///@param accessory 指标对象
- (void)updateSelectIndex:(NSInteger)index
                 maxValue:(CGFloat)maxValue
                 minValue:(CGFloat)minValue
               accecssory:(LABStockAccessoryBase *)accessory;

@end

NS_ASSUME_NONNULL_END
