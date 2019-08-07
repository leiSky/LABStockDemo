//
//  LABStockSelectBarMoreView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LABStockSelectBarMoreView;

NS_ASSUME_NONNULL_BEGIN

@interface LABStockSelectBarItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger iden;

+ (instancetype)itemWithTitle:(NSString *)title iden:(NSInteger)iden;

@end

@protocol LABStockSelectBarMoreViewDelegate<NSObject>
@optional
- (void)moreView:(LABStockSelectBarMoreView *)moreView didSelectItem:(LABStockSelectBarItem *)item superItem:(id)superItem;

@end

///选择更多展开的View
@interface LABStockSelectBarMoreView : UIView

@property (nonatomic, strong) NSArray<LABStockSelectBarItem *> *items;
@property (nonatomic, weak) id superItem;
@property (nonatomic, weak) id<LABStockSelectBarMoreViewDelegate> delegate;
///容器
@property (nonatomic, strong) UIScrollView *scrollView;

- (instancetype)initWithItems:(NSArray<LABStockSelectBarItem *> *)items;

///外部不需要调用
- (void)initUI;

@end

NS_ASSUME_NONNULL_END
