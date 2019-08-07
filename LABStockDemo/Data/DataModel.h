//
//  DataModel.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/24.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataModel : NSObject

///时间,格式：yyyymmddhhmm
@property (nonatomic, assign) long long dataTime;
///开盘价
@property (nonatomic, assign) double openPrice;
///最高价
@property (nonatomic, assign) double highPrice;
///最低价
@property (nonatomic, assign) double lowPrice;
///收盘价
@property (nonatomic, assign) double closePrice;
///成交量
@property (nonatomic, assign) double volume;
///成交额
@property (nonatomic, assign) double totalMoney;
///预留字段
@property (nonatomic, copy) NSString *moreStr;

@end

NS_ASSUME_NONNULL_END
