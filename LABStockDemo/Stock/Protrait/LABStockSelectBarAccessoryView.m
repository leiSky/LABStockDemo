//
//  LABStockSelectBarAccessoryView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockSelectBarAccessoryView.h"
#import <LABStockFramework/LABStockFramework.h>

@interface LABStockSelectBarAccessoryView ()

@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation LABStockSelectBarAccessoryView

- (void)initUI {
    [super initUI];
}

- (void)layoutSubviews {
    [self upDate];
}

///让选中的指标显示在中间
- (void)scrollToCenterAnimate:(BOOL)animate {
    CGFloat minX = 0;
    CGFloat maxX = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
    CGFloat selectX = self.selectBtn.center.x - CGRectGetWidth(self.frame)/2.0;
    CGFloat offsetX = MIN(maxX, MAX(minX, selectX));
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animate];
}

- (void)didClickBtnAction:(UIButton *)sender {
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreView:didSelectItem:superItem:)]) {
        [self.delegate moreView:self didSelectItem:self.items[sender.tag-100] superItem:self.superItem];
    }
    [self scrollToCenterAnimate:YES];
}

- (void)upDate {
    self.selectBtn.selected = NO;
    self.selectBtn = nil;
    
    LABAccessoryType type = [LABStockVariable curStockAccessoryType];
    [self.items enumerateObjectsUsingBlock:^(LABStockSelectBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = self.scrollView.subviews[idx];
        if (btn && obj.iden == type) {
            btn.selected = YES;
            self.selectBtn = btn;
        }
    }];
    if (!self.selectBtn) {
        UIButton *firstBtn = self.scrollView.subviews.firstObject;
        if (firstBtn && [firstBtn isKindOfClass:[UIButton class]]) {
            self.selectBtn = firstBtn;
            [self.selectBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    ///更新UI
    [self scrollToCenterAnimate:NO];
}

@end
