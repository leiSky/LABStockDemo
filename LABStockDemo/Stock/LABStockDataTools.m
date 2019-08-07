//
//  LABStockDataTools.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockDataTools.h"
#import "LABStockDataModel.h"
#import "LABStockQuoteViewData.h"

@implementation LABStockDataTools

#pragma mark --外部方法

///获取数据
///@param key 键值,用来对应不同的数据
///@param type 分时K线类型
///@return 对应的数据源数组
+ (NSArray<id<LABStockDataProtocol>> *)getStockDataForKey:(NSString *)key stockType:(LABStockType)type {
    NSArray<DataModel *> *data = [self getDataByKey:key dataType:[self getDataTypeForStockType:type]];
    if (!data) {
        return nil;
    }
    ///根据分时k线类型整理数据
    switch (type) {
        case LABStockTypeTimeLine:
            ///分时数据,不做处理
            break;
        case LABStockTypeKLine1Min:
            ///1分钟k线数据,不做处理
            break;
        case LABStockTypeKLine5Min:
            data = [self makeMinCycleWithSrcData:data iMin:5];
            break;
        case LABStockTypeKLine15Min:
            data = [self makeMinCycleWithSrcData:data iMin:15];
            break;
        case LABStockTypeKLine30Min:
            data = [self makeMinCycleWithSrcData:data iMin:30];
            break;
        case LABStockTypeKLine1Hour:
            data = [self makeOneHourCycleWithSrcData:data];
            break;
        case LABStockTypeKLine4Hour:
            data = [self makeHourCycleWithSrcData:data iHour:4];
            break;
        case LABStockTypeKLineDay:
            ///日线k线数据,不做处理
            break;
        case LABStockTypeKLineWeek:
            ///根据日线整理
            break;
        case LABStockTypeKLineMonth:
            ///根据日线整理
            break;
    }
    __block NSMutableArray *tempArray = [NSMutableArray array];
    __block LABStockDataModel<LABStockDataProtocol> *preModel = nil;
    [data enumerateObjectsUsingBlock:^(DataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LABStockDataModel *model = [[LABStockDataModel alloc] initWith:obj];
        model.preDataModel = preModel;
        if (preModel) {
            preModel.nextDataModel = model;
        }
        [tempArray addObject:model];
        preModel = model;
    }];
    return [tempArray copy];
}

+ (void)queryStockDataForKey:(NSString *)key stockType:(LABStockType)type completed:(dispatch_block_t)completed {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<DataModel *> *data = [self makeMinDataModel];
        [self putData:data key:key dataType:[self getDataTypeForStockType:type]];
        if (completed) {
            completed();
        }
    });
}

+ (void)queryStockQuoteForKey:(NSString *)key stockType:(LABStockType)type completed:(void (^)(LABStockQuoteViewData * _Nonnull))completed {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LABStockQuoteViewData *quoteData = [[LABStockQuoteViewData alloc] init];
        quoteData.nameAndCode = key;
        quoteData.openPrice = 6666;
        quoteData.curPrice = 7777;
        quoteData.radio24h = 0.25;
        quoteData.riseAndFall24h = 2222;
        quoteData.high24h = 8888;
        quoteData.low24h = 6666;
        quoteData.volume24h = 6789;
        if (completed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 completed(quoteData);
            });
        }
    });
}

#pragma mark --内部方法

///获取分钟线数据数组
///@param srcData 要整理的分钟线数组
///@param iMin 需要整理出的分钟数
///@return 整理出后对应分钟数的分钟数据数组
+ (NSArray<DataModel *> *)makeMinCycleWithSrcData:(NSArray<DataModel *> *)srcData iMin:(NSInteger)iMin {
    NSMutableArray *tempArray = [NSMutableArray array];///用来存放整理后数据的零时数组
    __block DataModel *data;
    __block long long dataTime;
    [srcData enumerateObjectsUsingBlock:^(DataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL bNewMin;
        if (data) {
            NSInteger min1 = data.dataTime / 100;//年月日时分
            NSInteger min2 = obj.dataTime / 100;
            if (min1 == min2) {//相同分钟数据
                bNewMin = NO;
            }else {
                //不同分钟
                NSInteger h1 = min1 / 100;//年月日时
                NSInteger h2 = min2 / 100;
                if (h1 == h2) {
                    //同一小时
                    NSInteger m1 = min1%100;//分钟
                    m1 = (m1/iMin) * iMin;
                    NSInteger m2 = min2%100;
                    m2 = (m2/iMin) * iMin;
                    if (m1 == m2) {
                        bNewMin = NO;
                    }else {
                        bNewMin = YES;
                        ///以最新的一条
                        dataTime = h2*10000 + m2*100;
                    }
                }else {
                    //不同小时
                    bNewMin = YES;
                    //以最新一条
                    NSInteger m2 = min2%100;//分
                    m2 = (m2/iMin) * iMin;//归档分钟
                    dataTime = h2*10000 + m2*100;
                }
            }
        }else {
            bNewMin = YES;
            ///以最新的一条
            NSInteger min2 = obj.dataTime / 100;//年月日时分
            NSInteger h2 = min2 / 100;//年月日时
            NSInteger m2 = min2 % 100;//分
            m2 = (m2/iMin) * iMin;//归档分钟
            dataTime = h2*10000 + m2*100;
        }
        if (bNewMin) {///一条新数据
            data = [[DataModel alloc] init];
            data.dataTime = dataTime;
            data.openPrice = obj.openPrice;
            data.closePrice = obj.closePrice;
            data.highPrice = obj.highPrice;
            data.lowPrice = obj.lowPrice;
            data.volume = obj.volume;
            data.totalMoney = obj.totalMoney;
            data.moreStr = obj.moreStr;
            [tempArray addObject:data];
        }else {//同一条数据
            //data.dataTime = obj.dataTime;
            if (obj.highPrice > data.highPrice) {
                data.highPrice = obj.highPrice;
            }
            if (obj.lowPrice < data.lowPrice) {
                data.lowPrice = obj.lowPrice;
            }
            data.closePrice = obj.closePrice;
            data.volume += obj.volume;
            data.totalMoney += obj.totalMoney;
        }
    }];
    return [tempArray copy];
}

///整理1小时线数据数组
///@param srcData 要整理的分钟线数组
///@return 1小时数据数组
+ (NSArray<DataModel *> *)makeOneHourCycleWithSrcData:(NSArray<DataModel *> *)srcData {
    NSMutableArray *tempArray = [NSMutableArray array];///用来存放整理后数据的零时数组
    __block DataModel *data;
    __block long long dataTime;
    [srcData enumerateObjectsUsingBlock:^(DataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///判断年月一样的就是同一年月日时
        BOOL bNewMonth;
        if (data) {
            NSInteger h1 = data.dataTime / 10000;//年月日时
            NSInteger h2 = obj.dataTime / 10000;
            if (h1 == h2) {//相同就是同一年月日时
                bNewMonth = NO;
            }else {
                bNewMonth = YES;
                ///以最新的一条
                dataTime = h2*10000;
            }
        }else {
            bNewMonth = YES;
            NSInteger h2 = obj.dataTime / 10000;///年月日时
            ///以最新的一条
            dataTime = h2*10000;
        }
        if (bNewMonth) {//一条新数据
            data = [[DataModel alloc] init];
            data.dataTime = dataTime;
            data.openPrice = obj.openPrice;
            data.closePrice = obj.closePrice;
            data.highPrice = obj.highPrice;
            data.lowPrice = obj.lowPrice;
            data.volume = obj.volume;
            data.totalMoney = obj.totalMoney;
            data.moreStr = obj.moreStr;
            [tempArray addObject:data];
        }else {//同一条数据
            //data.dataTime = obj.dataTime;
            if (obj.highPrice > data.highPrice) {
                data.highPrice = obj.highPrice;
            }
            if (obj.lowPrice < data.lowPrice) {
                data.lowPrice = obj.lowPrice;
            }
            data.closePrice = obj.closePrice;
            data.volume += obj.volume;
            data.totalMoney += obj.totalMoney;
        }
    }];
    return [tempArray copy];
}

///整理其他小时线数据数组
///@param srcData 要整理的分钟线数组
///@param iHour 需要整理出的小时数
///@return 整理出后对应小时数的小时数据数组
+ (NSArray<DataModel *> *)makeHourCycleWithSrcData:(NSArray<DataModel *> *)srcData iHour:(NSInteger)iHour {
    ///先整理成1小时线
    NSArray<DataModel *> *kline = [self makeOneHourCycleWithSrcData:srcData];
    NSMutableArray *tempArray = [NSMutableArray array];///用来存放整理后数据的零时数组
    __block DataModel *data;
    __block long long dataTime;
    [kline enumerateObjectsUsingBlock:^(DataModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///判断年月一样的就是同一年月日时
        BOOL beNewHour;
        if (data) {
            NSInteger t1 = data.dataTime / 10000;//年月日时
            NSInteger t2 = obj.dataTime / 10000;
            if (t1 == t2) {//相同就是同一年月日时
                beNewHour = NO;
            }else {
                NSInteger d1 = t1/100;//年月日
                NSInteger d2 = t2/100;
                if (d1 == d2) {//日期相同,判断小时
                    NSInteger h1 = t1 % 100;//小时
                    h1 = (h1/iHour) * iHour;
                    NSInteger h2 = t2 % 100;
                    h2 = (h2/iHour) * iHour;
                    if (h1 == h2) {
                        beNewHour = NO;
                    }else {
                        beNewHour = YES;
                        ///新的一条数据,计算出新的数据的时间,以最新的一条
                        dataTime = d2*1000000 + h2*10000;
                    }
                }else {
                    beNewHour = YES;
                    //以最新的一条
                    NSInteger h2 = t2 % 100;//小时
                    h2 = (h2/iHour) * iHour;//归档小时
                    dataTime = d2*1000000 + h2*10000;
                }
            }
        }else {
            beNewHour = YES;
            ///以最新的一条
            NSInteger t2 = obj.dataTime / 10000;//年月日时
            NSInteger d2 = t2/100;//年月日
            NSInteger h2 = t2 % 100;//小时
            h2 = (h2/iHour) * iHour;//归档小时
            dataTime = d2*1000000 + h2*10000;
        }
        if (beNewHour) {///一条新数据
            data = [[DataModel alloc] init];
            data.dataTime = dataTime;
            data.openPrice = obj.openPrice;
            data.closePrice = obj.closePrice;
            data.highPrice = obj.highPrice;
            data.lowPrice = obj.lowPrice;
            data.volume = obj.volume;
            data.totalMoney = obj.totalMoney;
            data.moreStr = obj.moreStr;
            [tempArray addObject:data];
        }else {//同一条数据
            //data.dataTime = obj.dataTime;
            if (obj.highPrice > data.highPrice) {
                data.highPrice = obj.highPrice;
            }
            if (obj.lowPrice < data.lowPrice) {
                data.lowPrice = obj.lowPrice;
            }
            data.closePrice = obj.closePrice;
            data.volume += obj.volume;
            data.totalMoney += obj.totalMoney;
        }
    }];
    return [tempArray copy];
}

///根据传入的分时K线类型返回需要获取内存数据的key
///@param type 分时K线类型
///@return 获取内存数据对应的key,几分钟数据
+ (NSInteger)getDataTypeForStockType:(LABStockType)type {
    switch (type) {
        case LABStockTypeTimeLine:
        case LABStockTypeKLine1Min:
        case LABStockTypeKLine5Min:
        case LABStockTypeKLine15Min:
        case LABStockTypeKLine30Min:
        case LABStockTypeKLine1Hour:
        case LABStockTypeKLine4Hour:
            ///使用1分钟数据
            return 1;
            break;
        case LABStockTypeKLineDay:
        case LABStockTypeKLineWeek:
        case LABStockTypeKLineMonth:
            //使用日线数据
            return 0;
            break;
    }
}

///根据key和类型获取对应key下面的对应类型的数据
///@param key 键值(可能是股票代码或者其他唯一的key)
///@param type 需要获取的数据类型,几分钟数据等
///@return 数据集数组<DataModel *>,不存在数据时会返回nil
+ (NSArray<DataModel *> *)getDataByKey:(NSString *)key dataType:(NSInteger)type {
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSArray<DataModel *> *> *> *dataDic = [self getCacheDataDic];
    NSMutableDictionary<NSString *, NSArray<DataModel *> *> *keyDataDic = [dataDic objectForKey:key];
    if (!keyDataDic) {
        return nil;
    }
    NSArray<DataModel *> *dataArray = [keyDataDic objectForKey:[@(type) stringValue]];
    if (!dataArray) {
        return nil;
    }
    return [dataArray copy];
}

+ (void)putData:(NSArray<DataModel *> *)data key:(NSString *)key dataType:(NSInteger)type {
    if (!data || !key || key.length<= 0) {
        return;
    }
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSArray<DataModel *> *> *> *dataDic = [self getCacheDataDic];
    NSMutableDictionary<NSString *, NSArray<DataModel *> *> *keyDataDic = [dataDic objectForKey:key];
    if (!keyDataDic) {
        keyDataDic = [NSMutableDictionary dictionary];
        [dataDic setObject:keyDataDic forKey:key];
        
        [keyDataDic setObject:data forKey:[@(type) stringValue]];
        return;
    }
    NSArray<DataModel *> *dataArray = [keyDataDic objectForKey:[@(type) stringValue]];
    if (!dataArray) {
        [keyDataDic setObject:data forKey:[@(type) stringValue]];
    }
    ///TODO:存在,合并两份数据
}

///获取缓存数据的字典
///
///第一层字典的key为获取传入的键值,第二层字典的key为获取字典传入的数据类型
+ (NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSArray<DataModel *> *> *> *)getCacheDataDic {
    static NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSArray<DataModel *> *> *> *dataDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataDic = [NSMutableDictionary dictionary];
    });
    return dataDic;
}

///将获取的分时数据转换为Model数组
+ (NSArray<DataModel *> *)makeMinDataModel {
    NSArray<NSDictionary *> *minArray = [self getMinData];
    NSMutableArray<DataModel *> *tempMinArray = [NSMutableArray array];
    for (NSDictionary *dic in minArray) {
        DataModel *model = [[DataModel alloc] init];
        
        model.dataTime = [dic[@"time"] longLongValue];
        model.openPrice = [dic[@"open"] doubleValue];
        model.highPrice = [dic[@"high"] doubleValue];
        model.lowPrice = [dic[@"low"] doubleValue];
        model.closePrice = [dic[@"close"] doubleValue];
        model.volume = [dic[@"volume"] doubleValue];
        model.totalMoney = [dic[@"amount"] doubleValue];
        
        [tempMinArray addObject:model];
    }
    return [tempMinArray copy];
}

///从本地获取原始1分钟数据
+ (NSArray<NSDictionary *> *)getMinData {
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minData" ofType:@"plist"]];
    return array;
    
}

@end
