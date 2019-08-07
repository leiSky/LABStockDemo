//
//  LABStockLandspaceAccessory.h
//  LABStockDemo
//
//  Created by leixt on 2019/7/26.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABStockSelectBarMoreView.h"

NS_ASSUME_NONNULL_BEGIN

@class LABStockLandspaceAccessory;

@protocol LABStockLandspaceAccessoryDelegate<NSObject>
@optional
- (void)accessoryView:(LABStockLandspaceAccessory *)accessoryView didSelectItem:(LABStockSelectBarItem *)item;

@end

@interface LABStockLandspaceAccessory : UIView

@property (nonatomic, strong) NSArray<LABStockSelectBarItem *> *items;
@property (nonatomic, weak) id<LABStockLandspaceAccessoryDelegate> delegate;

- (instancetype)initWithItems:(NSArray<LABStockSelectBarItem *> *)items;

@end

NS_ASSUME_NONNULL_END
