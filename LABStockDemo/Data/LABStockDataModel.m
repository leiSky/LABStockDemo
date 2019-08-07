//
//  LABStockDataModel.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/25.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockDataModel.h"
#import <LABStockFramework/LABStockFramework.h>

@interface LABStockDataModel()

@property (nonatomic, strong) DataModel *dataModel;

@end;

@implementation LABStockDataModel

- (instancetype)initWith:(DataModel *)data {
    if ([super init]) {
        self.dataModel = data;
    }
    return self;
}

- (id<LABStockDataProtocol>)preModel {
    return self.preDataModel;
}

- (id<LABStockDataProtocol>)nextModel {
    return self.nextDataModel;
}

- (NSNumber *)ms_open {
    return @(self.dataModel.openPrice);
}

- (NSNumber *)ms_close {
    return @(self.dataModel.closePrice);
}

- (NSNumber *)ms_high {
    return @(self.dataModel.highPrice);
}

- (NSNumber *)ms_low {
    return @(self.dataModel.lowPrice);
}

- (CGFloat)ms_volume {
    return self.dataModel.volume;
}

- (CGFloat)ms_totalMoney {
    return self.dataModel.totalMoney;
}

- (NSString *)ms_date {
    return [@(self.dataModel.dataTime) stringValue];
}

@end
