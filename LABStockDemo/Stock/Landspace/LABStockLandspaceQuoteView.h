//
//  LABStockLandspaceQuoteView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockQuoteView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LABStockLandspaceQuoteView : LABStockQuoteView

@property (nonatomic, copy) dispatch_block_t closeBlock;

@end

NS_ASSUME_NONNULL_END
