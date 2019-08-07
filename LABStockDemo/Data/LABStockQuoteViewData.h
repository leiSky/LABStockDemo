//
//  LABStockQuoteViewData.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///报价盘数据
@interface LABStockQuoteViewData : NSObject

///名称/代码
@property (nonatomic, copy) NSString *nameAndCode;
///开盘价
@property (nonatomic, assign) double openPrice;
///最新价
@property (nonatomic, assign) double curPrice;
///24h涨跌
@property (nonatomic, assign) double riseAndFall24h;
///24h涨跌幅
@property (nonatomic, assign) double radio24h;
///24h最高价
@property (nonatomic, assign) double high24h;
///24h最低价
@property (nonatomic, assign) double low24h;
///24h总成交量
@property (nonatomic, assign) double volume24h;

@end

NS_ASSUME_NONNULL_END
