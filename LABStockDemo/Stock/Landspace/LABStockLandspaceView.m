//
//  LABStockLandspaceView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockLandspaceView.h"
#import "LABStockLandspaceQuoteView.h"
#import "LABStockSelectBarLandspace.h"
#import "LABStockLandspaceAccessory.h"
#import "LABStock.h"
#import "LABStcokSelectMaskView.h"
#import "LABStockDataTools.h"
#import <Masonry/Masonry.h>

@interface LABStockLandspaceView ()<LABStockSelectBarDelegate, LABStockDelegate, LABStockDataSource, LABStockLandspaceAccessoryDelegate>

///报价盘
@property (nonatomic, strong) LABStockLandspaceQuoteView *quoteView;
///分时K线类型选择条
@property (nonatomic, strong) LABStockSelectBarLandspace *selectBarView;
///指标选择
@property (nonatomic, strong) LABStockLandspaceAccessory *accessoryView;
///分时K线绘图
@property (nonatomic, strong) LABStock *labStock;
///选中数据展示的遮罩
@property (nonatomic, strong) LABStcokSelectMaskView *selectMaskView;

@end

@implementation LABStockLandspaceView

#pragma mark --初始化方法

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

#pragma mark --外部方法

- (void)start {
    ///开始网络请求数据等
    [LABStockDataTools queryStockDataForKey:@"888888" stockType:[LABStockVariable curStockType] completed:^{
        [self.labStock draw];
    }];
    [LABStockDataTools queryStockQuoteForKey:@"888888" stockType:[LABStockVariable curStockType] completed:^(LABStockQuoteViewData * _Nonnull quoteData) {
        [self.quoteView setData:quoteData];
    }];
}

- (void)setCloseBlock:(dispatch_block_t)closeBlock {
    _closeBlock = closeBlock;
    self.quoteView.closeBlock = closeBlock;
}

#pragma mark --内部方法

- (void)initUI {
    self.backgroundColor = [UIColor LABStock_stockBgColor];
    [self addSubview:self.quoteView];
    [self.quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@(40));
    }];
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor LABStock_bgColor];
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.quoteView.mas_bottom).offset(10);
    }];
    
    [self addSubview:self.selectBarView];
    [self.selectBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(containerView.mas_bottom);
        make.height.equalTo(@(30));
    }];
    
    [containerView addSubview:self.labStock.containerView];
    [self.labStock.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(containerView);
    }];
    
    UIView *accessoryContainer = [UIView new];
    accessoryContainer.backgroundColor = [UIColor LABStock_bgColor];
    [containerView addSubview:accessoryContainer];
    [accessoryContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(containerView);
        make.left.equalTo(self.labStock.containerView.mas_right);
    }];
    
    [accessoryContainer addSubview:self.accessoryView];
    [self.accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(accessoryContainer).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        make.width.equalTo(@(55));
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.labStock draw];
    });
}

#pragma mark --懒加载,getter

- (LABStockLandspaceQuoteView *)quoteView {
    if (!_quoteView) {
        _quoteView = [[NSBundle mainBundle] loadNibNamed:@"LABStockLandspaceQuoteView" owner:nil options:nil].firstObject;
        _quoteView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _quoteView;
}

- (LABStockSelectBarProtrait *)selectBarView {
    if (!_selectBarView) {
        _selectBarView = [[NSBundle mainBundle] loadNibNamed:@"LABStockSelectBarLandspace" owner:nil options:nil].firstObject;
        _selectBarView.backgroundColor = [UIColor LABStock_bgColor];
        _selectBarView.delegate = self;
    }
    return _selectBarView;
}

- (LABStockLandspaceAccessory *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[LABStockLandspaceAccessory alloc] initWithItems:@[[LABStockSelectBarItem itemWithTitle:@"ASI" iden:LABAccessoryTypeASI],
                                                                             [LABStockSelectBarItem itemWithTitle:@"BIAS" iden:LABAccessoryTypeBIAS],
                                                                             [LABStockSelectBarItem itemWithTitle:@"BRAR" iden:LABAccessoryTypeBRAR],
                                                                             [LABStockSelectBarItem itemWithTitle:@"BOLL" iden:LABAccessoryTypeBOLL],
                                                                             [LABStockSelectBarItem itemWithTitle:@"CCI" iden:LABAccessoryTypeCCI],
                                                                             [LABStockSelectBarItem itemWithTitle:@"CR" iden:LABAccessoryTypeCR],
                                                                             [LABStockSelectBarItem itemWithTitle:@"DMA" iden:LABAccessoryTypeDMA],
                                                                             [LABStockSelectBarItem itemWithTitle:@"DMI" iden:LABAccessoryTypeDMI],
                                                                             [LABStockSelectBarItem itemWithTitle:@"EMV" iden:LABAccessoryTypeEMV],
                                                                             [LABStockSelectBarItem itemWithTitle:@"EXPMA" iden:LABAccessoryTypeEXPMA],
                                                                             [LABStockSelectBarItem itemWithTitle:@"KDJ" iden:LABAccessoryTypeKDJ],
                                                                             [LABStockSelectBarItem itemWithTitle:@"MACD" iden:LABAccessoryTypeMACD],
                                                                             [LABStockSelectBarItem itemWithTitle:@"MIKE" iden:LABAccessoryTypeMIKE],
                                                                             [LABStockSelectBarItem itemWithTitle:@"OBV" iden:LABAccessoryTypeOBV],
                                                                             [LABStockSelectBarItem itemWithTitle:@"PSY" iden:LABAccessoryTypePSY],
                                                                             [LABStockSelectBarItem itemWithTitle:@"ROC" iden:LABAccessoryTypeROC],
                                                                             [LABStockSelectBarItem itemWithTitle:@"RSI" iden:LABAccessoryTypeRSI],
                                                                             [LABStockSelectBarItem itemWithTitle:@"SAR" iden:LABAccessoryTypeSAR],
                                                                             [LABStockSelectBarItem itemWithTitle:@"TRIX" iden:LABAccessoryTypeTRIX],
                                                                             [LABStockSelectBarItem itemWithTitle:@"VR" iden:LABAccessoryTypeVR],
                                                                             [LABStockSelectBarItem itemWithTitle:@"W%R" iden:LABAccessoryTypeWR],
                                                                             [LABStockSelectBarItem itemWithTitle:@"WVAD" iden:LABAccessoryTypeWVAD]]];
        _accessoryView.backgroundColor = [UIColor colorWithR:44.0f g:57.0f b:82.0f a:1.0f];
        _accessoryView.delegate = self;
    }
    return _accessoryView;
}

- (LABStock *)labStock {
    if (!_labStock) {
        _labStock = [[LABStock alloc] initWithFrame:self.bounds dataSource:self delegate:self direction:LABScreenDirectionProtrait];
    }
    return _labStock;
}

- (LABStcokSelectMaskView *)selectMaskView {
    if (!_selectMaskView) {
        _selectMaskView = [[NSBundle mainBundle] loadNibNamed:@"LABStcokSelectMaskView" owner:nil options:nil].firstObject;
        _selectMaskView.backgroundColor = [UIColor LABStock_stockBgColor];
        _selectMaskView.hidden = YES;
    }
    return _selectMaskView;
}

#pragma mark --LABStockSelectBarDelegate

- (void)labStockSelectBar:(LABStockSelectBar *)selectBar selectStockType:(LABStockType)type {
    [self.labStock selectedStockType:type];
}

#pragma mark --LABStockDelegate, LABStockDataSource

- (NSArray<id<LABStockDataProtocol>> *)labStock:(LABStock *)stock stockDataOfType:(LABStockType)type {
    return [LABStockDataTools getStockDataForKey:@"888888" stockType:type];
}

- (void)labStock:(LABStock *)stock longPressSelectedModel:(id<LABStockDataProtocol>)model {
    if (!model) {
        //隐藏遮罩
        self.selectMaskView.hidden = YES;
    }else {
        ///显示上面的遮罩View
        if (self.selectMaskView.hidden) {
            self.selectMaskView.hidden = NO;
        }
        self.selectMaskView.selectmodel = model;
        ///隐藏选择条点击出现的更多view
        [self.selectBarView hiddenMoreView];
    }
}

- (void)labStockDidScaleMax:(LABStock *)stock {
    NSLog(@"已经放大到最大了,不能再放大了");
}

- (void)labStockDidScaleMin:(LABStock *)stock {
    NSLog(@"已经缩小到最小了,不能再缩小了");
}

- (void)labStockDidScrollToHead:(LABStock *)stock {
    NSLog(@"已经滑动最头上了,判断是否可以加载更多历史数据,若有则加载刷新,没有则提示");
}

- (void)labStockDidScrollToTail:(LABStock *)stock {
    NSLog(@"已经滑动最尾了");
}

#pragma mark --LABStockLandspaceAccessoryDelegate

- (void)accessoryView:(LABStockLandspaceAccessory *)accessoryView didSelectItem:(LABStockSelectBarItem *)item {
    [self.labStock draw];
}

@end
