//
//  LABStockMainView.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABStockConstant.h"

@protocol LABStockDataProtocol;
@class LABStockMainView;

NS_ASSUME_NONNULL_BEGIN

///绘图view的代理回调
@protocol LABStockMainViewDelegate <NSObject>
@optional
///手动长按时的回调,通知上层,更新选中数据时也会调用此方法
///@param mainView mainView
///@param model 长按选中的数据,为nil时,则表示长按结束
- (void)labStockMainView:(LABStockMainView *)mainView longPressSelectedModel:(nullable id<LABStockDataProtocol>)model;

///手动缩放到最小时回调
///@param mainView mainView
- (void)labStockMainViewDidScaleMin:(LABStockMainView *)mainView;

///手动缩放到最大时回调
///@param mainView mainView
- (void)labStockMainViewDidScaleMax:(LABStockMainView *)mainView;

///手动滑动到头(最前面)时回调
///@param mainView mainView
- (void)labStockMainViewDidScrollToHead:(LABStockMainView *)mainView;

///手动滑动到尾(最后面)时回调
///@param mainView mainView
- (void)labStockMainViewDidScrollToTail:(LABStockMainView *)mainView;

@end

///标识代理实现方法的结构体，在代理的set方法中赋值
struct LABStockMainViewDelegateFlags {
    BOOL stockLongPressFlag     : 1;
    BOOL stockDidScaleMinFlag   : 1;
    BOOL stockDidScaleMaxFlag   : 1;
    BOOL stockScrollToHeadFlag  : 1;
    BOOL stockScrollToTailFlag  : 1;
};

///行情部分的主View
@interface LABStockMainView : UIView

///回调代理
@property (nonatomic, weak) id<LABStockMainViewDelegate> delegate;
@property (nonatomic, assign) struct LABStockMainViewDelegateFlags delegateFlags;

///页面类型
///
///通过初始化方法传入赋值
@property (nonatomic, assign, readonly) LABStockType type;

///方向
///
///通过初始化方法传入赋值
@property (nonatomic, assign, readonly) LABScreenDirection direction;

///总数据源数组
///
///通过初始化方法传入或者更新数据时赋值
@property (nonatomic, strong, readonly) NSArray<id<LABStockDataProtocol>> *lineModels;

///初始化方法
///@param models 所有的数据
///@param direction 屏幕的方向
///@param type 页面类型
///@return LABStockMainView
- (instancetype)initWithModels:(NSArray<id<LABStockDataProtocol>> *)models
                     direction:(LABScreenDirection)direction
                     stockType:(LABStockType)type NS_REQUIRES_SUPER;

///重绘刷新的方法
///@param models 所有的数据
///@param flag 是否滚动到最新
- (void)reDrawWithModels:(NSArray<id<LABStockDataProtocol>> *)models
             scrollToNew:(BOOL)flag NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
