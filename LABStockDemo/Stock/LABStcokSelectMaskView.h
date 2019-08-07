//
//  LABStcokSelectMaskView.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LABStockFramework/LABStockFramework.h>

NS_ASSUME_NONNULL_BEGIN

///选中数据显示的View
@interface LABStcokSelectMaskView : UIView

@property (nonatomic, strong) id<LABStockDataProtocol> selectmodel;

@end

NS_ASSUME_NONNULL_END
