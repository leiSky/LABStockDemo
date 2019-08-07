//
//  LABStockTimeUtils.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/15.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeUtils.h"

@protocol LABStockTimeFormatProtocol <NSObject>
@required

- (NSString *)stringFromDate:(NSDate *)date;

- (NSDate *)dateFromString:(NSString *)string;

- (NSTimeInterval)timeIntervalFromString:(NSString *)string;

@end

@interface LABStockTimeFormat : NSObject<LABStockTimeFormatProtocol>

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation LABStockTimeFormat

- (instancetype)initWithFormat:(NSString *)format {
    if ([super init]) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:format];
    }
    return self;
}

- (NSString *)stringFromDate:(NSDate *)date {
    return [_formatter stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    return [_formatter dateFromString:string];
}

- (NSTimeInterval)timeIntervalFromString:(NSString *)string {
    NSDate *date = [self dateFromString:string];
    return [date timeIntervalSince1970];
}

@end

static NSDictionary<NSString *, id<LABStockTimeFormatProtocol>> *formatDic;

@implementation LABStockTimeUtils

#pragma mark --内部方法
+ (id<LABStockTimeFormatProtocol>)getTimeFormat:(LABStockTimeStyle)type {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatDic = @{
                      [@(LABStockTimeStyle_HH_MM) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"HH:mm"],
                      [@(LABStockTimeStyle_HH_MM_SS) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"HH:mm:ss"],
                      [@(LABStockTimeStyle_MM_DD_HH_mm) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"MM-dd HH:mm"],
                      [@(LABStockTimeStyle_YY_MM) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yy-MM"],
                      [@(LABStockTimeStyle_YY_MM_DD) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yy-MM-dd"],
                      [@(LABStockTimeStyle_YY_MM_DD_HH_MM) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yy-MM-dd HH:mm"],
                      [@(LABStockTimeStyle_YYYY_MM_DD) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yyyy-MM-dd"],
                      [@(LABStockTimeStyle_YYYY_MM_DD_HH_MM) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yyyy-MM-dd HH:mm"],
                      [@(LABStockTimeStyle_YYYY_MM_DD_HH_MM_SS) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yyyy-MM-dd HH:mm:ss"],
                      [@(LABStockTimeStyle_YYYYMMDDHHMMSS) stringValue] : [[LABStockTimeFormat alloc] initWithFormat:@"yyyyMMddHHmmss"]
                      };
    });
    return formatDic[[@(type) stringValue]];
}

#pragma mark --外部方法

+ (NSDate *)getDateFromString:(NSString *)dateStr type:(LABStockTimeStyle)type {
    id<LABStockTimeFormatProtocol> format = [self getTimeFormat:type];
    if (!format) {
        return nil;
    }
    return [format dateFromString:dateStr];
}

+ (NSString *)getStringFromDate:(NSDate *)date type:(LABStockTimeStyle)type {
    id<LABStockTimeFormatProtocol> format = [self getTimeFormat:type];
    if (!format) {
        return nil;
    }
    return [format stringFromDate:date];
}

+ (NSString *)stringByDateString:(NSString *)dateStr stockType:(LABStockType)type {
    id<LABStockTimeFormatProtocol> format1 = [self getTimeFormat:LABStockTimeStyle_YYYYMMDDHHMMSS];
    if (!format1) {
        return nil;
    }
    //根据类型格式化时间
    LABStockTimeStyle style;
    switch (type) {
        case LABStockTypeTimeLine:
        case LABStockTypeKLine1Min:
        case LABStockTypeKLine15Min:
        case LABStockTypeKLine5Min:
        case LABStockTypeKLine30Min:
        case LABStockTypeKLine1Hour:
        case LABStockTypeKLine4Hour:
            style = LABStockTimeStyle_MM_DD_HH_mm;
            break;
        case LABStockTypeKLineDay:
        case LABStockTypeKLineWeek:
            style = LABStockTimeStyle_YY_MM_DD;
            break;
        case LABStockTypeKLineMonth:
            style = LABStockTimeStyle_YY_MM;
            break;
    }
    id<LABStockTimeFormatProtocol> format2 = [self getTimeFormat:style];
    if (!format2) {
        return nil;
    }
    NSDate *a_date = [format1 dateFromString:dateStr];
    NSString *date = [format2 stringFromDate:a_date];
    return date;
}

@end
