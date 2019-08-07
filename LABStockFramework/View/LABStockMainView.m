//
//  LABStockMainView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockMainView.h"

@implementation LABStockMainView

- (instancetype)initWithModels:(NSArray<id<LABStockDataProtocol>> *)models direction:(LABScreenDirection)direction stockType:(LABStockType)type {
    if ([super init]) {
        _lineModels = models;
        _direction = direction;
        _type = type;
    }
    return self;
}

- (void)reDrawWithModels:(NSArray<id<LABStockDataProtocol>> *)models scrollToNew:(BOOL)flag {
    _lineModels = models;
}

- (void)setDelegate:(id<LABStockMainViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.stockLongPressFlag = [delegate respondsToSelector:@selector(labStockMainView:longPressSelectedModel:)];
    _delegateFlags.stockDidScaleMinFlag = [delegate respondsToSelector:@selector(labStockMainViewDidScaleMin:)];
    _delegateFlags.stockDidScaleMaxFlag = [delegate respondsToSelector:@selector(labStockMainViewDidScaleMax:)];
    _delegateFlags.stockScrollToHeadFlag = [delegate respondsToSelector:@selector(labStockMainViewDidScrollToHead:)];
    _delegateFlags.stockScrollToTailFlag = [delegate respondsToSelector:@selector(labStockMainViewDidScrollToTail:)];
}

@end
