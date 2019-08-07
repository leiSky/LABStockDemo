//
//  LABStockViewPos.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LABStockDataProtocol;

NS_ASSUME_NONNULL_BEGIN

///标记绘制数据的位置信息
@interface LABStockViewPos : NSObject

///绘制在屏幕上开始的位置X
@property (nonatomic, assign) CGFloat xPosition;
///开始绘制数据在总数据中的索引
@property (nonatomic, assign) NSInteger begin;
///结束绘制数据在总数据中的索引
@property (nonatomic, assign) NSInteger end;
///右边还有没有k线
@property (nonatomic, assign) NSInteger endPos;
///所有的数据
@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *models;

- (NSRange)getDrawModelRange;

- (void)upDateWithLineModels:(NSArray<id<LABStockDataProtocol>> *)models screenWidth:(CGFloat)screenWidth;

@end

NS_ASSUME_NONNULL_END
