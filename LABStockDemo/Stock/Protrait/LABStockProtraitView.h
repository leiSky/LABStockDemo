//
//  LABStockProtraitView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///竖屏时显示的View,包含报价盘,分时K线选择条,选中数据遮罩,分时K线绘制区域等
@interface LABStockProtraitView : UIView

///开始请求数据
- (void)start;

///刷新
- (void)refresh;

///获取显示的高度
+ (CGFloat)getViewHeight;

@end

NS_ASSUME_NONNULL_END
