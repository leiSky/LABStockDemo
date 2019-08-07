//
//  LABStockSelectBar.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LABStockFramework/LABStockFramework.h>

@class LABStockSelectBar;

NS_ASSUME_NONNULL_BEGIN

@protocol LABStockSelectBarDelegate<NSObject>
@optional
///分时k线的类型选择
- (void)labStockSelectBar:(LABStockSelectBar *)selectBar selectStockType:(LABStockType)type;
///指标的类型选择
- (void)labStockSelectBar:(LABStockSelectBar *)selectBar selectAccessoryType:(LABAccessoryType)type;

@end

///分时K线类型选择条
@interface LABStockSelectBar : UIView

@property (nonatomic, weak) id<LABStockSelectBarDelegate> delegate;
///标题下方的指示器
@property (nonatomic, strong) UIView *indicatorView;
///根据类型,更新ui
- (void)upDateUI:(LABStockType)type;
///更新指示器的位置
- (void)updateIndicatorView:(UIButton *)btn;
///隐藏点击出现的更多view
- (void)hiddenMoreView;

@end

NS_ASSUME_NONNULL_END
