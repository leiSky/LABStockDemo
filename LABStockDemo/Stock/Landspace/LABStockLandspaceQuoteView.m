//
//  LABStockLandspaceQuoteView.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockLandspaceQuoteView.h"

@implementation LABStockLandspaceQuoteView

- (IBAction)closeBtnClick:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
