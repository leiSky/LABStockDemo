//
//  LABStock.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStock.h"
#import <Masonry/Masonry.h>

@interface LABStock ()<LABStockMainViewDelegate>

///存放各绘图View的VC
@property (nonatomic, strong) NSMutableDictionary<NSString *, LABStockMainView *> *_stockViewDic;
@property (nonatomic, assign) LABStockType curType;

@end

@implementation LABStock

#pragma mark --初始化

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<LABStockDataSource>)dataSource
                     delegate:(id<LABStockDelegate>)delegate
                    direction:(LABScreenDirection)direction {
    if ([super init]) {
        _delegate = delegate;
        _dataSource = dataSource;
        _direction = direction;
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.backgroundColor = [UIColor LABStock_bgColor];
        [self initUI];
    }
    return self;
}

#pragma mark --内部方法

- (void)initUI {
    self._stockViewDic = [NSMutableDictionary dictionary];
    LABStockType curType = [LABStockVariable curStockType];
    [self createStockViewByType:curType];
    _curType = curType;
}

- (LABStockMainView *)createStockViewByType:(LABStockType)type {
    NSArray<id<LABStockDataProtocol>> *models = [self.dataSource labStock:self stockDataOfType:type];
    LABStockMainView *stockView;
    if (type == LABStockTypeTimeLine) {//分时
        stockView = [[LABStockTimeLineMainView alloc] initWithModels:models direction:_direction stockType:type];
    }else {//k线
        stockView = [[LABStockKLineMainView alloc] initWithModels:models direction:_direction stockType:type];
    }
    stockView.delegate = self;
    stockView.backgroundColor = [UIColor LABStock_bgColor];
    [self.containerView addSubview:stockView];
    [stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    ///保存到字典中
    [self._stockViewDic setObject:stockView forKey:[@(type) stringValue]];
    return stockView;
}

#pragma mark --外部方法

- (void)draw {
    [self drawToNew:NO];
}

- (void)drawToNew:(BOOL)flag {
    @synchronized(self) {
        LABStockMainView *stockView = self.stockViewDic[[@(_curType) stringValue]];
        if (stockView) {
            [stockView reDrawWithModels:[self.dataSource labStock:self stockDataOfType:_curType] scrollToNew:flag];
        }
    }
}

- (void)selectedStockType:(LABStockType)type {
    LABStockMainView *lastStockView = self.stockViewDic[[@(_curType) stringValue]];
    lastStockView.hidden = YES;
    
    LABStockMainView *curStockView = self.stockViewDic[[@(type) stringValue]];
    if (!curStockView) {
        curStockView = [self createStockViewByType:type];
    }
    curStockView.hidden = NO;
    
    _curType = type;
    [self drawToNew:NO];
}

- (NSDictionary<NSString *, LABStockMainView *> *)stockViewDic {
    return [self._stockViewDic copy];
}

#pragma mark --LABStockMainViewDelegate

- (void)labStockMainView:(LABStockMainView *)mainView longPressSelectedModel:(id<LABStockDataProtocol>)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStock:longPressSelectedModel:)]) {
        [self.delegate labStock:self longPressSelectedModel:model];
    }
}

- (void)labStockMainViewDidScaleMax:(LABStockMainView *)mainView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockDidScaleMax:)]) {
        [self.delegate labStockDidScaleMax:self];
    }
}

- (void)labStockMainViewDidScaleMin:(LABStockMainView *)mainView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockDidScaleMin:)]) {
        [self.delegate labStockDidScaleMin:self];
    }
}

- (void)labStockMainViewDidScrollToHead:(LABStockMainView *)mainView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockDidScrollToHead:)]) {
        [self.delegate labStockDidScrollToHead:self];
    }
}

- (void)labStockMainViewDidScrollToTail:(LABStockMainView *)mainView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockDidScrollToTail:)]) {
        [self.delegate labStockDidScrollToTail:self];
    }
}

@end
