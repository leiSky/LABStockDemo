//
//  LABStockDataProtocol.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///分时K线数据模型协议
@protocol LABStockDataProtocol <NSObject>
///前一条数据
@property (nonatomic, strong, readonly) id<LABStockDataProtocol> preModel;
///后一条数据
@property (nonatomic, strong, readonly) id<LABStockDataProtocol> nextModel;
///开盘价
@property (nonatomic, strong, readonly) NSNumber *ms_open;
///收盘价
@property (nonatomic, strong, readonly) NSNumber *ms_close;
///最高价
@property (nonatomic, strong, readonly) NSNumber *ms_high;
///最低价
@property (nonatomic, strong, readonly) NSNumber *ms_low;
///成交额
@property (nonatomic, assign, readonly) CGFloat ms_totalMoney;
///成交量
@property (nonatomic, assign, readonly) CGFloat ms_volume;
///日期
@property (nonatomic, copy, readonly) NSString *ms_date;

@end

NS_ASSUME_NONNULL_END
