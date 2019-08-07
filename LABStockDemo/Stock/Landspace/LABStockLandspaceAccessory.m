//
//  LABStockLandspaceAccessory.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockLandspaceAccessory.h"
#import "UIColor+LABStock.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

const CGFloat acessoryItemHeight = 30;

@interface LABStockLandspaceAccessory()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation LABStockLandspaceAccessory

- (instancetype)initWithItems:(NSArray<LABStockSelectBarItem *> *)items {
    if ([super init]) {
        self.items = items;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    ///加边框
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithR:69.0f g:87.0f b:129.0f a:1.0f].CGColor;
    ///指标标题
    UILabel *lab = [UILabel new];
    lab.text = @"指标";
    lab.font = [UIFont systemFontOfSize:11];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor LABStock_selectedTextColor];
    [self addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(acessoryItemHeight));
    }];
    self.scrollView = ({
        UIScrollView *scrollView = [UIScrollView new];
        [self addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(lab.mas_bottom);
        }];
        ///按钮组
        __block UIButton *lastBtn;
        __block UIButton *firstBtn;
        LABAccessoryType type = [LABStockVariable curStockAccessoryType];
        [self.items enumerateObjectsUsingBlock:^(LABStockSelectBarItem  *obj, NSUInteger idx, BOOL *stop) {
            UIButton *btn = [self createBtnWithTitle:obj.title tag:idx];
            if (idx == 0) {
                firstBtn = btn;
            }
            if (obj.iden == type) {
                btn.selected = YES;
                self.selectBtn = btn;
            }
            [scrollView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(scrollView);
                make.height.equalTo(@(acessoryItemHeight));
                make.top.equalTo(lastBtn == nil ? scrollView.mas_top: lastBtn.mas_bottom);
                make.width.equalTo(scrollView);
            }];
            lastBtn = btn;
        }];
        [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(scrollView);
        }];
        if (!self.selectBtn && firstBtn && [firstBtn isKindOfClass:[UIButton class]]) {//如果没有选中的,默认选择第一个
            self.selectBtn = firstBtn;
            [self didClickBtnAction:self.selectBtn];
        }
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView;
    });
    
    ///延迟更新UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToCenterAnimate:NO];
    });
}

///让选中的指标显示在中间
- (void)scrollToCenterAnimate:(BOOL)animate {
    CGFloat minY = 0;
    CGFloat maxY = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.frame);
    CGFloat selectY = self.selectBtn.center.y - CGRectGetHeight(self.scrollView.frame)/2.0;
    CGFloat offsetY = MIN(maxY, MAX(minY, selectY));
    [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:animate];
}

- (UIButton *)createBtnWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitleColor:[UIColor LABStock_textColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:self action:@selector(didClickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)didClickBtnAction:(UIButton *)sender {
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    LABStockSelectBarItem *item = self.items[sender.tag];
    [LABStockVariable setCurStockAccessoryType:item.iden];
    if (self.delegate && [self.delegate respondsToSelector:@selector(accessoryView:didSelectItem:)]) {
        [self.delegate accessoryView:self didSelectItem:item];
    }
    [self scrollToCenterAnimate:YES];
}

@end
