//
//  LABStockAccessoryView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryView.h"
#import "LABStockDataProtocol.h"
#import "LABStockAccessoryBase.h"
#import "LABStockConstant.h"
#import "LABStockVariable.h"

@interface LABStockAccessoryView ()

@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
@property (nonatomic, strong) LABStockAccessoryBase *accessory;
@property (nonatomic, assign) CGFloat xPosition;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;


@end

@implementation LABStockAccessoryView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.accessory) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        self.accessory.minY = LABStockLineVolumeViewMinY;
        self.accessory.maxY = CGRectGetHeight(rect) - LABStockLineVolumeViewMinY;
        [self.accessory drawGraphWithCtx:ctx rect:rect xPosition:self.xPosition max:self.maxValue min:self.minValue];
    }
}

#pragma mark --外部方法

- (void)drawViewWithXPosition:(CGFloat)xPosition
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                     maxValue:(CGFloat)maxValue
                     minValue:(CGFloat)minValue
                   accecssory:(LABStockAccessoryBase *)accessory {
    self.xPosition = xPosition;
    self.drawLineModels = drawLineModels;
    self.maxValue = maxValue;
    self.minValue = minValue;
    self.accessory = accessory;
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

@end
