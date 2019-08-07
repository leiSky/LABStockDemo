//
//  LABStockLandspaceView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///横屏时显示的View,包含报价盘,指标选择,分时K线选择条,选中数据遮罩,分时K线绘制区域等
@interface LABStockLandspaceView : UIView

@property (nonatomic, copy) dispatch_block_t closeBlock;

///开始请求数据
- (void)start;

@end

NS_ASSUME_NONNULL_END
