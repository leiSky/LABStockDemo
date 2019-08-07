//
//  LABStockSelectBarMoreView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockSelectBarMoreView.h"
#import <Masonry/Masonry.h>
#import <LABStockFramework/LABStockFramework.h>

@implementation LABStockSelectBarItem

+ (instancetype)itemWithTitle:(NSString *)title iden:(NSInteger)iden {
    LABStockSelectBarItem *item = [[LABStockSelectBarItem alloc] init];
    item.title = title;
    item.iden = iden;
    return item;
}

@end

@implementation LABStockSelectBarMoreView

- (instancetype)initWithItems:(NSArray<LABStockSelectBarItem *> *)items {
    if ([super init]) {
        self.items = items;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.scrollView = ({
        UIScrollView *scrollView = [UIScrollView new];
        scrollView.backgroundColor = [[UIColor LABStock_stockBgColor] colorWithAlphaComponent:0.9];
        [self addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        //按钮组
        __block UIButton *lastBtn;
        [self.items enumerateObjectsUsingBlock:^(LABStockSelectBarItem  *obj, NSUInteger idx, BOOL *stop) {
            UIButton *btn = [self createBtnWithTitle:obj.title tag:idx];
            [scrollView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(scrollView);
                make.width.equalTo(@(50));
                make.left.equalTo(lastBtn == nil ? scrollView.mas_left : lastBtn.mas_right);
                make.height.equalTo(scrollView);
            }];
            lastBtn = btn;
        }];
        [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(scrollView);
        }];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView;
    });
}

- (UIButton *)createBtnWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitleColor:[UIColor LABStock_textColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    btn.tag = tag+100;
    [btn addTarget:self action:@selector(didClickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)didClickBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreView:didSelectItem:superItem:)]) {
        [self.delegate moreView:self didSelectItem:self.items[sender.tag-100] superItem:self.superItem];
    }
}

@end
