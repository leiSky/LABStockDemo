//
//  LABStockMA.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryBase.h"

@protocol LABStockDataProtocol;

typedef NS_ENUM(NSInteger, LABStockMAType) {
    LABStockMAType5 = 5,
    LABStockMAType10 = 10,
    LABStockMAType30 = 30,
    LABStockMAType60 = 60
};

NS_ASSUME_NONNULL_BEGIN

///MA指标
@interface LABStockMA : LABStockAccessoryBase

///MA中包含的类型,类型详见LABStockMAType
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *types;

///初始化方法
///@param lineModels 绘制的数据
///@param types MA类型数组
///@return MA指标对象
- (instancetype)initWithLineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels MATypes:(NSArray<NSNumber *> *)types;

@end

NS_ASSUME_NONNULL_END
