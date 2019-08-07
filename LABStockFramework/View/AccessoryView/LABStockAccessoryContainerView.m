//
//  LABStockAccessoryContainerView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockAccessoryContainerView.h"
#import "LABStockAccessoryBgView.h"
#import "LABStockAccessoryView.h"
#import "LABStockAccessoryBase.h"
#import "LABStockConstant.h"
#import "UIColor+LABStock.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

#import "LABStockASI.h"
#import "LABStockBIAS.h"
#import "LABStockBOLL.h"
#import "LABStockCCI.h"
#import "LABStockDMA.h"
#import "LABStockDMI.h"
#import "LABStockEMV.h"
#import "LABStockKDJ.h"
#import "LABStockMIKE.h"
#import "LABStockRSI.h"
#import "LABStockWR.h"
#import "LABStockMACD.h"
#import "LABStockBRAR.h"
#import "LABStockCR.h"
#import "LABStockEXPMA.h"
#import "LABStockOBV.h"
#import "LABStockPSY.h"
#import "LABStockROC.h"
#import "LABStockSAR.h"
#import "LABStockTRIX.h"
#import "LABStockVR.h"
#import "LABStockWVAD.h"

@interface LABStockAccessoryContainerView ()

///网格背景View
@property (nonatomic, strong) LABStockAccessoryBgView *bgView;
///绘制指标View
@property (nonatomic, strong) LABStockAccessoryView *accessoryView;

///数据范围,最大最小值
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

//指标
@property (nonatomic, strong) LABStockAccessoryBase *accessory;

@end

@implementation LABStockAccessoryContainerView

#pragma mark --初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.accessoryView];
    [self.accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(self).offset(LABStockScrollViewTopGap);
    }];
}

#pragma mark --懒加载,getter

- (LABStockAccessoryBgView *)bgView {
    if (!_bgView) {
        _bgView = [LABStockAccessoryBgView new];
        _bgView.backgroundColor = [UIColor LABStock_bgColor];
    }
    return _bgView;
}

- (LABStockAccessoryView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [LABStockAccessoryView new];
        _accessoryView.backgroundColor = [UIColor clearColor];
    }
    return _accessoryView;
}

#pragma mark --外部方法

- (void)drawViewWithXPosition:(CGFloat)xPosition
                   lineModels:(NSArray<id<LABStockDataProtocol>> *)lineModels
                   drawModels:(NSArray<id<LABStockDataProtocol>> *)drawLineModels
                    drawRange:(NSRange)range
                  selectIndex:(NSInteger)index {
    /**
     LABAccessoryTypeASI,   //ASI
     LABAccessoryTypeBIAS,  //BIAS
     LABAccessoryTypeBOLL,  //BOLL
     LABAccessoryTypeCCI,   //CCI
     LABAccessoryTypeDMA,   //DMA
     LABAccessoryTypeDMI,   //DMI
     LABAccessoryTypeEMV,   //EMV
     LABAccessoryTypeKDJ,   //KDJ
     LABAccessoryTypeMIKE,  //MIKE
     LABAccessoryTypeRSI,   //RSI
     LABAccessoryTypeMACD,  //MACD
     LABAccessoryTypeWR,    //WR
     LABAccessoryTypeBRAR,  //BRAR
     LABAccessoryTypeCR,    //CR,
     LABAccessoryTypeEXPMA, //EXPMA
     LABAccessoryTypeOBV,   //OBV
     LABAccessoryTypePSY,   //PSY
     LABAccessoryTypeROC,   //ROC
     LABAccessoryTypeSAR,   //SAR
     LABAccessoryTypeTRIX,  //TRIX
     LABAccessoryTypeVR,    //VR
     LABAccessoryTypeWVAD,  //WVAD
     */
    LABAccessoryType type = [LABStockVariable curStockAccessoryType];
    Class cls;
    switch (type) {
        case LABAccessoryTypeASI:
            cls = [LABStockASI class];
            break;
        case LABAccessoryTypeBIAS:
            cls = [LABStockBIAS class];
            break;
        case LABAccessoryTypeBOLL:
            cls = [LABStockBOLL class];
            break;
        case LABAccessoryTypeCCI:
            cls = [LABStockCCI class];
            break;
        case LABAccessoryTypeDMA:
            cls = [LABStockDMA class];
            break;
        case LABAccessoryTypeDMI:
            cls = [LABStockDMI class];
            break;
        case LABAccessoryTypeEMV:
            cls = [LABStockEMV class];
            break;
        case LABAccessoryTypeKDJ:
            cls = [LABStockKDJ class];
            break;
        case LABAccessoryTypeMIKE:
            cls = [LABStockMIKE class];
            break;
        case LABAccessoryTypeRSI:
            cls = [LABStockRSI class];
            break;
        case LABAccessoryTypeWR:
            cls = [LABStockWR class];
            break;
        case LABAccessoryTypeBRAR:
            cls = [LABStockBRAR class];
            break;
        case LABAccessoryTypeCR:
            cls = [LABStockCR class];
            break;
        case LABAccessoryTypeEXPMA:
            cls = [LABStockEXPMA class];
            break;
        case LABAccessoryTypeOBV:
            cls = [LABStockOBV class];
            break;
        case LABAccessoryTypePSY:
            cls = [LABStockPSY class];
            break;
        case LABAccessoryTypeROC:
            cls = [LABStockROC class];
            break;
        case LABAccessoryTypeSAR:
            cls = [LABStockSAR class];
            break;
        case LABAccessoryTypeTRIX:
            cls = [LABStockTRIX class];
            break;
        case LABAccessoryTypeVR:
            cls = [LABStockVR class];
            break;
        case LABAccessoryTypeWVAD:
            cls = [LABStockWVAD class];
            break;
        case LABAccessoryTypeMACD:
        default:
            cls = [LABStockMACD class];
            break;
    }
    LABStockAccessoryBase *accessoey = [[cls alloc] initWithLineModels:lineModels];
    accessoey.range = range;
    [accessoey getMaxMin:range];
    self.accessory = accessoey;
    
    self.maxValue = accessoey.maxValue;
    self.minValue = accessoey.minValue;
    
    if (self.minValue > self.maxValue) {
        self.maxValue = 0.00;
        self.minValue = 0.00;
    }
    if (self.maxValue == self.minValue) {
        //处理特殊情况
        if (self.maxValue == 0) {
            self.maxValue = 2;
            self.minValue = 0;
        } else {
            self.maxValue = self.maxValue+self.maxValue/2.0;
            self.minValue = self.minValue-self.minValue/2.0;
        }
    }
    
    [self updateSelectIndex:index];
    [self.accessoryView drawViewWithXPosition:xPosition drawModels:drawLineModels maxValue:self.maxValue minValue:self.minValue accecssory:self.accessory];
}

- (void)updateSelectIndex:(NSInteger)index {
    [self.bgView updateSelectIndex:index maxValue:self.maxValue minValue:self.minValue accecssory:self.accessory];
}

@end
