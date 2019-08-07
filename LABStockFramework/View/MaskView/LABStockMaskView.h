//
//  LABStockMaskView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABStockConstant.h"

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface LABStockMaskView : UIView

///初始化时设置,用来格式化时间,必须赋值
@property (nonatomic, assign) LABStockType type;

///当前标记点的位置
@property (nonatomic, assign, readonly) CGPoint point;

///选中的数据模型
@property (nonatomic, strong, readonly) id<LABStockDataProtocol> selectModel;

///model中时间的显示Y坐标
@property (nonatomic, assign, readonly) CGFloat timeY;

///更新十字坐标的方法
///@param selectModel 当前选中的数据,时间等数据的来源
///@param point 选中数据对应的坐标点
///@param positionY 时间View的Y坐标,用来在时间View上面显示出当前的时间
- (void)updateSelectModel:(id<LABStockDataProtocol>)selectModel positionPoint:(CGPoint)point stockTimePositionY:(CGFloat)positionY;

#pragma mark --子类可重写的方法

///绘制十字线,子类可重写实现不同
///@param ctx 上下文
- (void)drawCrosslines:(CGContextRef)ctx;

///绘制选中model的时间,子类可重写实现不同
///@param ctx 上下文
- (void)drawTime:(CGContextRef)ctx;

///绘制选中model的值,子类可重写实现不同
///@param ctx 上下文
- (void)drawValue:(CGContextRef)ctx;

@end

NS_ASSUME_NONNULL_END
