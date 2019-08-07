//
//  LABStockDrawLine.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///绘制线
@interface LABStockDrawLine : NSObject

///初始化方法
///@param context 上下文
///@return LABStockDrawLine实例对象
- (instancetype)initWithContext:(CGContextRef)context;

///绘制线条
///@param lineColor 线条颜色
///@param positions 数据数组,NSValue(CGPonit)
- (void)drawWithColor:(UIColor *)lineColor positions:(NSArray<NSValue *> *)positions;

@end

NS_ASSUME_NONNULL_END
