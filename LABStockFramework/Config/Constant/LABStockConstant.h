//
//  LABStockConstant.h
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//  固定值和枚举定义

#ifndef LABStockConstant_h
#define LABStockConstant_h

///K线最小的厚度
#define LABStockLineMinThick 0.5
///K线最大的宽度
#define LABStockLineMaxWidth 20
///K线图最小的宽度
#define LABStockLineMinWidth 2
///分时线的宽度
#define LABStockTimeLineWidth 1
///上下影线宽度
#define LABStockShadowLineWidth 1.2
///指标线宽度
#define LABStockAccessoryLineWidth 1.2
///分时k线图上可画区域最小的Y
#define LABStockLineMainViewMinY 4
///分时k线图的成交量和副图上最小的Y
#define LABStockLineVolumeViewMinY 1
///分时K线图的日期高度
#define LABStockLineDateHigh 18
///滑动区域放置MA等指标的高度
#define LABStockScrollViewTopGap 14
///分时K线图缩放界限
#define LABStockLineScaleBound 0.03
///分时K线的缩放因子
#define LABStockLineScaleFactor 0.06
///指标的字体大小
#define LABStockAccessoryFont 8

#define LABStockSafeBlock(b) \
    do {\
        if ([[NSThread currentThread] isMainThread]) {\
            b();\
        }else {\
            dispatch_async(dispatch_get_main_queue(), ^{\
                b();\
            });\
        }\
    } while (0);

#endif /* LABStockConstant_h */

typedef NS_ENUM(NSInteger, LABStockType) {
    LABStockTypeTimeLine = 1,     //分时
    LABStockTypeKLine1Min,        //1分钟
    LABStockTypeKLine5Min,        //5分钟
    LABStockTypeKLine15Min,       //15分钟
    LABStockTypeKLine30Min,       //30分钟
    LABStockTypeKLine1Hour,       //1小时
    LABStockTypeKLine4Hour,       //4小时
    LABStockTypeKLineDay,         //日线
    LABStockTypeKLineWeek,        //周线
    LABStockTypeKLineMonth        //月线
};

typedef NS_ENUM(NSInteger, LABAccessoryType) {
    LABAccessoryTypeASI = 1,      //ASI
    LABAccessoryTypeBIAS,         //BIAS
    LABAccessoryTypeBOLL,         //BOLL
    LABAccessoryTypeCCI,          //CCI
    LABAccessoryTypeDMA,          //DMA
    LABAccessoryTypeDMI,          //DMI
    LABAccessoryTypeEMV,          //EMV
    LABAccessoryTypeKDJ,          //KDJ
    LABAccessoryTypeMIKE,         //MIKE
    LABAccessoryTypeRSI,          //RSI
    LABAccessoryTypeMACD,         //MACD
    LABAccessoryTypeWR,           //WR
    LABAccessoryTypeBRAR,         //BRAR
    LABAccessoryTypeCR,           //CR,
    LABAccessoryTypeEXPMA,        //EXPMA
    LABAccessoryTypeOBV,          //OBV
    LABAccessoryTypePSY,          //PSY
    LABAccessoryTypeROC,          //ROC
    LABAccessoryTypeSAR,          //SAR
    LABAccessoryTypeTRIX,         //TRIX
    LABAccessoryTypeVR,           //VR
    LABAccessoryTypeWVAD,         //WVAD
};

typedef NS_ENUM(NSInteger, LABScreenDirection) {
    LABScreenDirectionProtrait = 1, //竖屏
    LABScreenDirectionLandscape,    //横屏
};
