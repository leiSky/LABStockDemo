//
//  LABStockDataTools.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LABStockFramework/LABStockFramework.h>

@class LABStockQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface LABStockDataTools : NSObject

///获取分时K线数据
///@param key 键值,比如股票代码等
///@param type 获取的数据类型
///@return 分时K线数据数组
+ (NSArray<id<LABStockDataProtocol>> *)getStockDataForKey:(NSString *)key stockType:(LABStockType)type;

///查询分时K线数据
///@param key 键值,比如股票代码等
///@param type 获取的数据类型
///@param completed 完成的回调
+ (void)queryStockDataForKey:(NSString *)key stockType:(LABStockType)type completed:(dispatch_block_t)completed;

///查询分时K线报价盘数据
///@param key 键值,比如股票代码等
///@param type 获取的数据类型
///@param completed 完成的回调
+ (void)queryStockQuoteForKey:(NSString *)key stockType:(LABStockType)type completed:(void(^)(LABStockQuoteViewData *))completed;

@end

NS_ASSUME_NONNULL_END
