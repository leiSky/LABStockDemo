//
//  LABStockQuoteView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LABStockQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface LABStockQuoteView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioLabel;
@property (weak, nonatomic) IBOutlet UILabel *highPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *volume24Label;

@property (nonatomic, strong) LABStockQuoteViewData *data;

@end

NS_ASSUME_NONNULL_END
