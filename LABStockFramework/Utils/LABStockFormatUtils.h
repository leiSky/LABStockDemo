//
//  LABStockFormatUtils.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LABStockFormatUtils : NSObject

///保留指定小数位，四舍五入
///@param doubleValue 浮点数
///@param scale 小数位
///@return NSString 不同精度的浮点数
+ (NSString *)getStringWithDouble:(double)doubleValue andScale:(int)scale;

///保留指定小数位，需要指定格式模式(四舍五入,只舍,只入等)
///@param doubleValue 浮点数
///@param scale 小数位
///@return NSString 不同精度的浮点数
+ (NSString *)getStringWithDouble:(double)doubleValue andScale:(int)scale andMode:(NSRoundingMode)mode;

@end

NS_ASSUME_NONNULL_END
