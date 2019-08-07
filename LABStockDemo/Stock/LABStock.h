//
//  LABStock.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <LABStockFramework/LABStockFramework.h>

@class LABStock;

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol LABStockDataSource <NSObject>
@required
///获取数据源的方法,根据传入的需要获取的分时K线类型,返回对应的数据源数组
///@param stock stock
///@param type 获取的分时K线类型
///@return 数据源数组,元素实现LABStockDataProtocol协议
- (NSArray <id<LABStockDataProtocol>> *)labStock:(LABStock *)stock stockDataOfType:(LABStockType)type;

@end

@protocol LABStockDelegate <NSObject>
@optional
///手动长按时的回调,通知上层,更新选中数据时也会调用此方法
///@param stock stock
///@param model 长按选中的数据,为nil时,则表示长按结束
- (void)labStock:(LABStock *)stock longPressSelectedModel:(nullable id<LABStockDataProtocol>)model;

///手动缩放到最小时回调
///@param stock stock
- (void)labStockDidScaleMin:(LABStock *)stock;

///手动缩放到最大时回调
///@param stock stock
- (void)labStockDidScaleMax:(LABStock *)stock;

///手动滑动到头(最前面)时回调
///@param stock stock
- (void)labStockDidScrollToHead:(LABStock *)stock;

///手动滑动到尾(最后面)时回调
///@param stock stock
- (void)labStockDidScrollToTail:(LABStock *)stock;

@end

@interface LABStock : NSObject

@property (nonatomic, weak) id<LABStockDataSource> dataSource;
@property (nonatomic, weak) id<LABStockDelegate> delegate;

@property (nonatomic, assign, readonly) LABScreenDirection direction;

///容器View
@property (nonatomic, strong, readonly) UIView *containerView;
///存放各绘图View的VC
@property (nonatomic, strong, readonly) NSDictionary<NSString *, LABStockMainView *> *stockViewDic;

///初始化函数
///@param frame frame
///@param dataSource 数据源
///@param delegate 代理
///@param direction 方向
///@return 实例
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<LABStockDataSource>)dataSource
                     delegate:(id<LABStockDelegate>)delegate
                    direction:(LABScreenDirection)direction;

///开始绘制
- (void)draw;

///开始绘制并滑到最新
///flag 是否到最新
- (void)drawToNew:(BOOL)flag;

///选中某个类型
///@param type 分时K线类型
- (void)selectedStockType:(LABStockType)type;

@end

NS_ASSUME_NONNULL_END
