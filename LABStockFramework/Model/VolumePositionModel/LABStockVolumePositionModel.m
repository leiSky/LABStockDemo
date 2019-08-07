//
//  LABStockVolumePositionModel.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockVolumePositionModel.h"

@implementation LABStockVolumePositionModel

+ (instancetype)modelWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    LABStockVolumePositionModel *model = [[LABStockVolumePositionModel alloc] init];
    model.startPoint = startPoint;
    model.endPoint = endPoint;
    return model;
}

@end
