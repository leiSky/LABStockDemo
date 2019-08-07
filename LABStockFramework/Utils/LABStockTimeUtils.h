//
//  LABStockTimeUtils.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LABStockConstant.h"

NS_ASSUME_NONNULL_BEGIN

///时间格式类型
typedef NS_ENUM(NSUInteger, LABStockTimeStyle) {
    LABStockTimeStyle_HH_MM,                //HH:mm
    LABStockTimeStyle_HH_MM_SS,             //HH:mm:ss
    
    LABStockTimeStyle_MM_DD_HH_mm,          //MM-dd HH:mm
    
    LABStockTimeStyle_YY_MM,                //yy-MM
    LABStockTimeStyle_YY_MM_DD,             //yy-MM-dd
    LABStockTimeStyle_YY_MM_DD_HH_MM,       //yy-MM-dd HH:mm
    
    LABStockTimeStyle_YYYY_MM_DD,           //yyyy-MM-dd
    LABStockTimeStyle_YYYY_MM_DD_HH_MM,     //yyyy-MM-dd HH:mm
    LABStockTimeStyle_YYYY_MM_DD_HH_MM_SS,  //yyyy-MM-dd HH:mm:ss
    LABStockTimeStyle_YYYYMMDDHHMMSS        //yyyymmddhhmmss
};

@interface LABStockTimeUtils : NSObject

///根据日期对象和格式获取相应的字符串时间
///@param date 日期对象
///@param type 日期类型
///@return 根据类型格式化好的日期字符串
+ (NSString *)getStringFromDate:(NSDate *)date type:(LABStockTimeStyle)type;

///根据字符串和格式获取相应的日期对象
///@param dateStr 字符串时间
///@param type 日期类型
///@return 将时间字符串格式化好的日期对象
+ (NSDate *)getDateFromString:(NSString *)dateStr type:(LABStockTimeStyle)type;

///根据行情分时k线类型,格式化好日期,在内部定义了分时K线k类型对应的时间类型
///@param date 字符串时间,格式为LABStockTimeStyle_YYYYMMDDHHMMSS
///@param type 分时k线类型
///@return 格式化好后对应的分时K线时间字符串
+ (NSString *)stringByDateString:(NSString *)date stockType:(LABStockType)type;

@end

NS_ASSUME_NONNULL_END
