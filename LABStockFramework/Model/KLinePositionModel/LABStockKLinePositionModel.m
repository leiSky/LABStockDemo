//
//  LABStockKLinePositionModel.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockKLinePositionModel.h"

@implementation LABStockKLinePositionModel

+ (instancetype)initWithOpen:(CGPoint)open close:(CGPoint)close high:(CGPoint)high low:(CGPoint)low accessory:(CGPoint)accessory {
    LABStockKLinePositionModel *model = [[LABStockKLinePositionModel alloc] init];
    model.openPoint = open;
    model.closePoint = close;
    model.highPoint = high;
    model.lowPoint = low;
    model.accessoryPoint = accessory;
    return model;
}

@end
