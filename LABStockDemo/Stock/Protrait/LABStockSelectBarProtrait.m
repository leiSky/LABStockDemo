//
//  LABStockSelectBarProtrait.m
//  LABStockDemo
//
//  Created by leixt on 2019/7/22.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockSelectBarProtrait.h"
#import "LABStockSelectBarAccessoryView.h"
#import <Masonry/Masonry.h>

@interface LABStockSelectBarProtrait ()<LABStockSelectBarMoreViewDelegate>

///分时按钮
@property (weak, nonatomic) IBOutlet UIButton *timeLineBtn;
///1分按钮
@property (weak, nonatomic) IBOutlet UIButton *min1Btn;
///5分按钮
@property (weak, nonatomic) IBOutlet UIButton *min5Btn;
///15分按钮
@property (weak, nonatomic) IBOutlet UIButton *min15Btn;
///30分按钮
@property (weak, nonatomic) IBOutlet UIButton *min30Btn;
///1小时时按钮
@property (weak, nonatomic) IBOutlet UIButton *oneHourBtn;
///指标按钮
@property (weak, nonatomic) IBOutlet UIButton *accessoryBtn;
///保存选中的按钮
@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) LABStockSelectBarAccessoryView *accessoryBtnClickView;
@property (nonatomic, strong) NSArray<LABStockSelectBarItem *> *maccessoryBtnViewItems;

@end

@implementation LABStockSelectBarProtrait

- (void)awakeFromNib {
    self.maccessoryBtnViewItems = @[[LABStockSelectBarItem itemWithTitle:@"ASI" iden:LABAccessoryTypeASI],
                                    [LABStockSelectBarItem itemWithTitle:@"BIAS" iden:LABAccessoryTypeBIAS],
                                    [LABStockSelectBarItem itemWithTitle:@"BRAR" iden:LABAccessoryTypeBRAR],
                                    [LABStockSelectBarItem itemWithTitle:@"BOLL" iden:LABAccessoryTypeBOLL],
                                    [LABStockSelectBarItem itemWithTitle:@"CCI" iden:LABAccessoryTypeCCI],
                                    [LABStockSelectBarItem itemWithTitle:@"CR" iden:LABAccessoryTypeCR],
                                    [LABStockSelectBarItem itemWithTitle:@"DMA" iden:LABAccessoryTypeDMA],
                                    [LABStockSelectBarItem itemWithTitle:@"DMI" iden:LABAccessoryTypeDMI],
                                    [LABStockSelectBarItem itemWithTitle:@"EMV" iden:LABAccessoryTypeEMV],
                                    [LABStockSelectBarItem itemWithTitle:@"EXPMA" iden:LABAccessoryTypeEXPMA],
                                    [LABStockSelectBarItem itemWithTitle:@"KDJ" iden:LABAccessoryTypeKDJ],
                                    [LABStockSelectBarItem itemWithTitle:@"MACD" iden:LABAccessoryTypeMACD],
                                    [LABStockSelectBarItem itemWithTitle:@"MIKE" iden:LABAccessoryTypeMIKE],
                                    [LABStockSelectBarItem itemWithTitle:@"OBV" iden:LABAccessoryTypeOBV],
                                    [LABStockSelectBarItem itemWithTitle:@"PSY" iden:LABAccessoryTypePSY],
                                    [LABStockSelectBarItem itemWithTitle:@"ROC" iden:LABAccessoryTypeROC],
                                    [LABStockSelectBarItem itemWithTitle:@"RSI" iden:LABAccessoryTypeRSI],
                                    [LABStockSelectBarItem itemWithTitle:@"SAR" iden:LABAccessoryTypeSAR],
                                    [LABStockSelectBarItem itemWithTitle:@"TRIX" iden:LABAccessoryTypeTRIX],
                                    [LABStockSelectBarItem itemWithTitle:@"VR" iden:LABAccessoryTypeVR],
                                    [LABStockSelectBarItem itemWithTitle:@"W%R" iden:LABAccessoryTypeWR],
                                    [LABStockSelectBarItem itemWithTitle:@"WVAD" iden:LABAccessoryTypeWVAD]];
    [super awakeFromNib];
}

#pragma mark --内部方法

- (void)updateSender:(UIButton *)sender {
    [self resetBtnColor];
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    [self updateIndicatorView:sender];
}

- (void)resetBtnColor {
    [self.accessoryBtnClickView removeFromSuperview];
    [self.accessoryBtn setTitleColor:[UIColor LABStock_textColor] forState:UIControlStateNormal];
    [self.accessoryBtn setBackgroundColor:[UIColor clearColor]];
    [self.accessoryBtn setImage:[UIImage imageNamed:@"icon-open" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

- (void)notiDelegateStockType:(LABStockType)type {
    [LABStockVariable setCurStockType:type];
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockSelectBar:selectStockType:)]) {
        [self.delegate labStockSelectBar:self selectStockType:type];
    }
}

- (void)notiDelegateAccessoryType:(LABAccessoryType)type {
    [LABStockVariable setCurStockAccessoryType:type];
    if (self.delegate && [self.delegate respondsToSelector:@selector(labStockSelectBar:selectAccessoryType:)]) {
        [self.delegate labStockSelectBar:self selectAccessoryType:type];
    }
}

#pragma mark --重写父类方法

- (void)upDateUI:(LABStockType)type {
    switch (type) {
        case LABStockTypeTimeLine:
            [self updateSender:self.timeLineBtn];
            break;
        case LABStockTypeKLine1Min:
            [self updateSender:self.min1Btn];
            break;
        case LABStockTypeKLine5Min:
            [self updateSender:self.min5Btn];
            break;
        case LABStockTypeKLine15Min:
            [self updateSender:self.min15Btn];
            break;
        case LABStockTypeKLine30Min:
            [self updateSender:self.min30Btn];
            break;
        case LABStockTypeKLine1Hour:
            [self updateSender:self.oneHourBtn];
            break;
        case LABStockTypeKLine4Hour:
        case LABStockTypeKLineDay:
        case LABStockTypeKLineWeek:
        case LABStockTypeKLineMonth:
        default:
            break;
    }
    ///更新指标
    [self.accessoryBtnClickView upDate];
}

- (void)hiddenMoreView {
    [self resetBtnColor];
}

#pragma mark --按钮点击事件

///分时点击
- (IBAction)timeLineClick:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeTimeLine];
}
///1分钟点击
- (IBAction)min1Click:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeKLine1Min];
}

///5分钟点击
- (IBAction)min5Click:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeKLine5Min];
}

///15分钟点击
- (IBAction)min15Click:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeKLine15Min];
}

///30分钟点击
- (IBAction)min30Click:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeKLine30Min];
}

///1小时时点击
- (IBAction)oneHourClick:(UIButton *)sender {
    [self updateSender:sender];
    [self notiDelegateStockType:LABStockTypeKLine1Hour];
}

///指标点击
- (IBAction)accessoryClick:(UIButton *)sender {
    if (!self.accessoryBtnClickView.superview) {
        [self resetBtnColor];
        if (![self.selectBtn isEqual:sender]) {
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sender setBackgroundColor:[UIColor LABStock_stockBgColor]];
        }
        [self.superview addSubview:self.accessoryBtnClickView];
        [self.accessoryBtnClickView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(@55);
        }];
        [self.accessoryBtn setImage:[UIImage imageNamed:@"icon-shouqi" inBundle:nil compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }else {
        [self resetBtnColor];
    }
}

#pragma mark --懒加载

- (LABStockSelectBarMoreView *)accessoryBtnClickView {
    if (!_accessoryBtnClickView) {
        _accessoryBtnClickView = [[LABStockSelectBarAccessoryView alloc] initWithItems:self.maccessoryBtnViewItems];
        _accessoryBtnClickView.delegate = self;
        _accessoryBtnClickView.superItem = self.accessoryBtn;
    }
    return _accessoryBtnClickView;
}

#pragma mark --LABStockSelectBarMoreViewDelegate

- (void)moreView:(LABStockSelectBarMoreView *)moreView didSelectItem:(LABStockSelectBarItem *)item superItem:(id)superItem {
    [moreView removeFromSuperview];
    [self resetBtnColor];
    [self notiDelegateAccessoryType:item.iden];
}

@end
