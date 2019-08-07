//
//  LABStockViewPos.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockViewPos.h"
#import "LABStockDataProtocol.h"
#import "LABStockVariable.h"

@implementation LABStockViewPos

- (instancetype)init {
    if ([super init]) {
        self.xPosition = [LABStockVariable lineGap] + [LABStockVariable lineWidth] / 2.0;
        self.begin = self.end = self.endPos = 0;
    }
    return self;
}

- (NSRange)getDrawModelRange {
    return NSMakeRange(self.begin, self.end-self.begin+1);
}

- (void)upDateWithLineModels:(NSArray<id<LABStockDataProtocol>> *)models screenWidth:(CGFloat)screenWidth {
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    NSInteger screenCount = screenWidth / (lineGap + lineWidth);
    if (models.count < screenCount) {//数据的数量小于屏幕绘制的数据量
        self.begin = 0;
        self.end = models.count-1;
    }else {
        if (self.endPos == 0) {//右边没有数据,看最新
            self.begin = models.count - screenCount;
            self.end = models.count - 1;
        }else {//说明有数据了,要更新数据,看历史
            //找到之前的开始索引在现在的数据源中的位置
            id<LABStockDataProtocol> beginModel = self.models[self.begin?:0];
            __block NSInteger index = 0;
            [models enumerateObjectsUsingBlock:^(id<LABStockDataProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.ms_date isEqualToString:beginModel.ms_date]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            self.begin = index;
            self.end = self.begin + screenCount - 1;
            self.endPos = models.count - self.end - 1;
            if (self.endPos < 0) {//若数据错误,调整下
                self.begin = models.count - screenCount;
                self.end = models.count - 1;
                self.endPos = 0;
            }
        }
    }
    self.models = models;
}

@end
