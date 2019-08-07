//
//  LABStockDataModel.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/25.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface LABStockDataModel : NSObject<LABStockDataProtocol>

@property (nonatomic, strong) id<LABStockDataProtocol> preDataModel;
@property (nonatomic, weak) id<LABStockDataProtocol> nextDataModel;

- (instancetype)initWith:(DataModel *)data;

@end

NS_ASSUME_NONNULL_END
