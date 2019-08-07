//
//  LABStcokSelectMaskView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStcokSelectMaskView.h"

@interface LABStcokSelectMaskView ()

@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation LABStcokSelectMaskView

- (void)setSelectmodel:(id<LABStockDataProtocol>)selectmodel {
    _selectmodel = selectmodel;
    id<LABStockDataProtocol> preModel = selectmodel.preModel;
    int pricePrecision = [LABStockVariable pricePrecision];
//    int volumePrecision = [LABStockVariable volumePrecision];
    double preClose = preModel.ms_close.doubleValue;
    UIColor *increaseColor = [UIColor LABStock_increaseColor];
    UIColor *decreaseColor = [UIColor LABStock_decreaseColor];
    UIColor *normalColor = [UIColor LABStock_textColor];
    
    UIColor *color = increaseColor;
    
    if (selectmodel.ms_open.doubleValue == preClose || !preModel) {
        color = normalColor;
    }else if (selectmodel.ms_open.doubleValue < preModel.ms_close.doubleValue) {
        color = decreaseColor;
    }
    NSString *openText = [LABStockFormatUtils getStringWithDouble:[selectmodel.ms_open doubleValue] andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.openLabel.text = [NSString stringWithFormat:@"开 %@", openText];
    self.openLabel.textColor = color;
    
    color = increaseColor;
    if (selectmodel.ms_high.doubleValue == preClose || !preModel) {
        color = normalColor;
    }else if (selectmodel.ms_high.doubleValue < preModel.ms_close.doubleValue) {
        color = decreaseColor;
    }
    NSString *highText = [LABStockFormatUtils getStringWithDouble:[selectmodel.ms_high doubleValue] andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.highLabel.text = [NSString stringWithFormat:@"高 %@", highText];
    self.highLabel.textColor = color;
    
    color = increaseColor;
    if (selectmodel.ms_low.doubleValue == preClose || !preModel) {
        color = normalColor;
    }else if (selectmodel.ms_low.doubleValue < preModel.ms_close.doubleValue) {
        color = decreaseColor;
    }
    NSString *lowText = [LABStockFormatUtils getStringWithDouble:[selectmodel.ms_low doubleValue] andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.lowLabel.text = [NSString stringWithFormat:@"低 %@", lowText];
    self.lowLabel.textColor = color;
    
    color = increaseColor;
    if (selectmodel.ms_close.doubleValue == preClose || !preModel) {
        color = normalColor;
    }else if (selectmodel.ms_close.doubleValue < preModel.ms_close.doubleValue) {
        color = decreaseColor;
    }
    NSString *closeText = [LABStockFormatUtils getStringWithDouble:[selectmodel.ms_close doubleValue] andScale:pricePrecision andMode:NSRoundDown];//舍弃
    self.closeLabel.text = [NSString stringWithFormat:@"收 %@", closeText];
    self.closeLabel.textColor = color;
    
    NSString *format = @"%.2f%%";
    double radio = 0.00;
    if (!preModel || preModel.ms_close.doubleValue == 0) {
        color = normalColor;
    }else {
        //计算
        radio = (selectmodel.ms_close.doubleValue - preModel.ms_close.doubleValue)/preModel.ms_close.doubleValue;
        if (radio < 0) {
            color = decreaseColor;
        }else if (radio == 0) {
            color = normalColor;
        }else {
            color = increaseColor;
            format = [@"+" stringByAppendingString:format];
        }
    }
    NSString *radioText = [NSString stringWithFormat:format, radio*100];
    self.radioLabel.text = [NSString stringWithFormat:@"幅 %@", radioText];
    self.radioLabel.textColor = color;
    
    self.volumeLabel.text = [NSString stringWithFormat:@"量 %@", [LABStockFormatUtils getStringWithDouble:selectmodel.ms_volume andScale:2]];
    
    NSDate *date = [LABStockTimeUtils getDateFromString:selectmodel.ms_date type:LABStockTimeStyle_YYYYMMDDHHMMSS];
    LABStockType type = [LABStockVariable curStockType];
    LABStockTimeStyle timeStyle = LABStockTimeStyle_YYYY_MM_DD_HH_MM_SS;
    switch (type) {
        case LABStockTypeTimeLine:
        case LABStockTypeKLine1Min:
        case LABStockTypeKLine5Min:
        case LABStockTypeKLine15Min:
        case LABStockTypeKLine30Min:
        case LABStockTypeKLine1Hour:
        case LABStockTypeKLine4Hour:
            timeStyle = LABStockTimeStyle_YY_MM_DD_HH_MM;
            break;
        case LABStockTypeKLineDay:
        case LABStockTypeKLineWeek:
            timeStyle = LABStockTimeStyle_YY_MM_DD;
            break;
        case LABStockTypeKLineMonth:
            timeStyle = LABStockTimeStyle_YY_MM;
            break;
        default:
            break;
    }
    self.timeLabel.text = [LABStockTimeUtils getStringFromDate:date type:timeStyle];
}

@end
