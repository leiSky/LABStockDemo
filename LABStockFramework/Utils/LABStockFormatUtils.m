//
//  LABStockFormatUtils.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/12.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockFormatUtils.h"

@implementation LABStockFormatUtils

+ (NSString *)getStringWithDouble:(double)doubleValue andScale:(int)scale {
    return [self getStringWithDouble:doubleValue andScale:scale andMode:NSRoundPlain];
}

+ (NSString *)getStringWithDouble:(double)doubleValue andScale:(int)scale andMode:(NSRoundingMode)mode {
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal = [[NSDecimalNumber alloc] initWithString:[@(doubleValue) stringValue]];
    NSDecimalNumber *roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    NSString *scaleString = [NSString stringWithFormat:@".%d",scale];
    NSString *string = [NSString stringWithFormat:@"%%%@f", scaleString];
    return [NSString stringWithFormat:string, [roundedOunces.stringValue doubleValue]];
}

@end
