//
//  LABStockTimeView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABStockConstant.h"

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

///时间绘制View
@interface LABStockTimeView : UIView

///绘制方法
///@param drawLineModels 绘制的数据模型数组
///@param drawPositions 绘制数据对应的坐标
///@param type 页面类型
- (void)drawViewWithDrawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                 drawPositions:(NSArray<NSValue *> *)drawPositions
                     stockType:(LABStockType)type;

@end

NS_ASSUME_NONNULL_END
