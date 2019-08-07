//
//  LABStockQuoteView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockQuoteView.h"
#import "LABStockQuoteViewData.h"
#import <LABStockFramework/LABStockFramework.h>

@implementation LABStockQuoteView

- (void)setData:(LABStockQuoteViewData *)data {
    _data = data;
    
    self.nameLabel.text = data.nameAndCode;
    
    int pricePrecision = [LABStockVariable pricePrecision];
    ///判断涨跌,选择颜色
    double openPrice = data.openPrice;
    double curPrice = data.curPrice;
    NSString *curPriceText = [LABStockFormatUtils getStringWithDouble:data.curPrice andScale:pricePrecision andMode:NSRoundDown];//舍弃
    UIColor *color = [UIColor LABStock_increaseColor];
    if (openPrice == curPrice || data.curPrice == 0 || data.openPrice == 0) {
        color = [UIColor LABStock_textColor];
        curPriceText = (data.curPrice == 0) ? @"--" : curPriceText;
    }else if (data.openPrice > data.curPrice) {
        color = [UIColor LABStock_decreaseColor];
    }
    self.priceLabel.text = curPriceText;
    self.priceLabel.textColor = color;
    
    NSString *format = @"%.2f%%";
    if (data.riseAndFall24h < 0) {
        color = [UIColor LABStock_decreaseColor];
    }else if (data.riseAndFall24h == 0) {
        color = [UIColor LABStock_textColor];
    }else {
        color = [UIColor LABStock_increaseColor];
        format = [@"+" stringByAppendingString:format];
    }
    self.radioLabel.text = data.curPrice == 0 ? @"--" : [NSString stringWithFormat:format, data.radio24h*100];
    self.radioLabel.textColor = color;
    
    self.highPriceLabel.text = data.curPrice == 0 ? @"--" : [LABStockFormatUtils getStringWithDouble:data.high24h andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.lowPriceLabel.text = data.curPrice == 0 ? @"--" : [LABStockFormatUtils getStringWithDouble:data.low24h andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.volume24Label.text = data.curPrice == 0 ? @"--" : [LABStockFormatUtils getStringWithDouble:data.volume24h andScale:0];
}

@end
