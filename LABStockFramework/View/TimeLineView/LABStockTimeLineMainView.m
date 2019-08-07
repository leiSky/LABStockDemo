//
//  LABStockTimeLineMainView.m
//  LABStockFramework
//
//  Created by leixt on 2019/7/11.
//  Copyright © 2019年 leixt. All rights reserved.
//

#import "LABStockTimeLineMainView.h"
#import "LABStockTimeLineContainerView.h"
#import "LABStockVolumeContainerView.h"
#import "LABStockAccessoryContainerView.h"
#import "LABStockTimeView.h"
#import "LABStockTimeLineMaskView.h"
#import "LABStockViewPos.h"
#import "LABStockVariable.h"
#import <Masonry/Masonry.h>

@interface LABStockTimeLineMainView()<UIGestureRecognizerDelegate>

///绘制数据源数组
@property (nonatomic, strong) NSArray<id<LABStockDataProtocol>> *drawLineModels;
///绘制数据源位置数组
@property (nonatomic, strong) NSArray<NSValue *> *drawLinePositionModels;
///分时部分
@property (nonatomic, strong) LABStockTimeLineContainerView *timeLineView;
///成交量部分
@property (nonatomic, strong) LABStockVolumeContainerView *volumeView;
///指标部分
@property (nonatomic, strong) LABStockAccessoryContainerView *accessoryView;
///时间部分
@property (nonatomic, strong) LABStockTimeView *timeView;
///遮罩部分
@property (nonatomic, strong) LABStockMaskView *maskView;
///绘制数据的相关信息
@property (nonatomic, strong) LABStockViewPos *drawPos;

///选中的索引
@property (nonatomic, assign) NSInteger selectIndex;
///选中的数据
@property (nonatomic, strong) id<LABStockDataProtocol> selectedModel;

///平移手势是否可用
@property (nonatomic, assign) BOOL panCanMove;

@end

///拖动手势减速相关
static int updateCount = 0;
static int currentCount = 0;
///起始速度
static CGPoint velocity;
///x方向减速速率,默认2000
static int velocityX = 2000;

@implementation LABStockTimeLineMainView

#pragma mark --初始化方法

- (instancetype)initWithModels:(NSArray<id<LABStockDataProtocol>> *)models direction:(LABScreenDirection)direction stockType:(LABStockType)type {
    if ([super initWithModels:models direction:direction stockType:type]) {
        self.drawPos = [[LABStockViewPos alloc] init];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    ///初始化需要的子View
    [self initSubViews];
    ///根据显示的方向布局,默认竖屏
    switch (self.direction) {
        case LABScreenDirectionLandscape:
            [self initLandscapeLayout];
            break;
        case LABScreenDirectionProtrait:
        default:
            [self initProtraitLayout];
            break;
    }
    ///添加手势
    [self initGesture];
}

///初始化需要的子View
- (void)initSubViews {
    _timeLineView = [LABStockTimeLineContainerView new];
    _timeLineView.backgroundColor = [UIColor clearColor];
    _volumeView = [LABStockVolumeContainerView new];
    _volumeView.backgroundColor = [UIColor clearColor];
    _accessoryView = [LABStockAccessoryContainerView new];
    _accessoryView.backgroundColor = [UIColor clearColor];
    _timeView = [LABStockTimeView new];
    _timeView.backgroundColor = [UIColor clearColor];
}

///竖屏布局
- (void)initProtraitLayout {
    ///加载TimeLineView
    [self addSubview:_timeLineView];
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
    }];
    ///加载VolumeView
    [self addSubview:_volumeView];
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.timeLineView.mas_bottom);
        make.height.equalTo(self.mas_height).multipliedBy([LABStockVariable volumeViewHeighRatio]);
    }];
    ///加载指标
    [self addSubview:_accessoryView];
    [_accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.volumeView.mas_bottom);
        make.height.equalTo(self.volumeView);
    }];
    ///添加时间
    [self addSubview:_timeView];
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.accessoryView.mas_bottom);
        make.height.equalTo(@(LABStockLineDateHigh));
    }];
}

///横屏布局
- (void)initLandscapeLayout {
    ///加载TimeLineView
    [self addSubview:_timeLineView];
    [_timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
    }];
    ///添加时间
    [self addSubview:_timeView];
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.timeLineView.mas_bottom);
        make.height.equalTo(@(LABStockLineDateHigh));
    }];
    ///加载VolumeView
    [self addSubview:_volumeView];
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.timeView.mas_bottom);
        make.height.equalTo(self.mas_height).multipliedBy([LABStockVariable volumeViewHeighRatio]);
    }];
    ///加载指标
    [self addSubview:_accessoryView];
    [_accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.volumeView.mas_bottom);
        make.height.equalTo(self.volumeView);
    }];
}

///添加手势
- (void)initGesture {
    ///添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(event_pinchAction:)];
    [self addGestureRecognizer:pinch];
    ///添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
    [self addGestureRecognizer:longPress];
    ///添加平移手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(event_panAction:)];
    [self addGestureRecognizer:pan];
    pan.delegate = self;
}

#pragma mark --外部方法

- (void)reDrawWithModels:(NSArray<id<LABStockDataProtocol>> *)models scrollToNew:(BOOL)flag {
    [super reDrawWithModels:models scrollToNew:flag];
    if (flag) {
        self.drawPos.endPos = 0;
    }
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

#pragma mark --内部方法

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.lineModels.count <= 0) {
        return;
    }
    ///更新绘制的数据源
    [self updateDrawModels];
    CGFloat xPosition = self.drawPos.xPosition;
    NSRange drawRange = [self.drawPos getDrawModelRange];
    ///绘制分时,并返回坐标
    self.drawLinePositionModels = [self.timeLineView drawViewWithXPosition:xPosition
                                                                lineModels:self.lineModels
                                                                drawModels:self.drawLineModels
                                                                 drawRange:drawRange
                                                               selectIndex:self.selectIndex];
    ///绘制成交量
    [self.volumeView drawViewWithXPosition:xPosition
                                lineModels:self.lineModels
                                drawModels:self.drawLineModels
                                 drawRange:drawRange
                               selectIndex:self.selectIndex];
    ///绘制指标
    [self.accessoryView drawViewWithXPosition:xPosition
                                   lineModels:self.lineModels
                                   drawModels:self.drawLineModels
                                    drawRange:drawRange
                                  selectIndex:self.selectIndex];
    ///绘制时间
    [self.timeView drawViewWithDrawModels:self.drawLineModels
                            drawPositions:self.drawLinePositionModels
                                stockType:self.type];
    if (self.maskView && !self.maskView.hidden) {
        ///更新遮罩
        NSInteger index = [self.drawLineModels indexOfObject:self.selectedModel];
        CGPoint p = [self.drawLinePositionModels[index] CGPointValue];
        ///分时绘制页面在其父类的LABStockScrollViewTopGap处开始,所以坐标还需加上这个值
        CGPoint p1 = CGPointMake(p.x, p.y+LABStockScrollViewTopGap);
        [self.maskView updateSelectModel:self.selectedModel positionPoint:p1 stockTimePositionY:CGRectGetMinY(self.timeView.frame)];
        ///更新选中的数据
        if (self.delegateFlags.stockLongPressFlag) {
            [self.delegate labStockMainView:self longPressSelectedModel:self.selectedModel];
        }
    }
}

///根据位置信息更新绘制的数据源
- (void)updateDrawModels {
    [self.drawPos upDateWithLineModels:self.lineModels screenWidth:CGRectGetWidth(self.frame)];
    self.drawLineModels = [self.lineModels subarrayWithRange:[self.drawPos getDrawModelRange]];
    ///更新MA等数据,有几种情况
    ///1.若游标在,则要重新计算当前点击的位置的数据
    ///2.游标不在,使用最后一条数据
    if (self.maskView && !self.maskView.isHidden) {
        //计算
        self.selectedModel = [self getRightModelByPoint:self.maskView.point];
    }else {
        self.selectedModel = self.lineModels.lastObject;
        self.selectIndex = self.lineModels.count - 1;
    }
}

///根据传入的点坐标(相对与self),计算出该点对于总Model的索引,并返回该点对应的model
///@param point 点坐标
- (id<LABStockDataProtocol>)getRightModelByPoint:(CGPoint)point {
    NSInteger index = [self getIndexInDrawModelsByPoint:point];
    self.selectIndex = self.drawPos.begin + index;
    return self.drawLineModels[index];
}

///根据传入的点坐标(相对与self),计算出该点对于在绘制Model中的索引
///@param point 点坐标
- (NSInteger)getIndexInDrawModelsByPoint:(CGPoint)point {
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    NSInteger index = point.x / (lineGap + lineWidth);
    if (index < 0) {
        index = 0;
    }
    if (index >= self.drawLineModels.count) {
        index = self.drawLineModels.count - 1;
    }
    if (index < 0) {
        index = 0;
    }
    return index;
}

- (void)updateStockView:(CGFloat)translationX {
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    self.drawPos.xPosition += translationX;
    NSInteger moveNum = ABS((self.drawPos.xPosition - (lineGap+lineWidth/2.0))/(lineGap+lineWidth));
    if (translationX > 0) {
        ///右滑,右移动
        if (self.drawPos.begin <= 0) {
            if (!panEnable) {
                return;
            }
            ////到最左边了
            self.drawPos.xPosition = lineGap+lineWidth/2.0;
            ///通知代理
            if (self.delegateFlags.stockScrollToHeadFlag) {
                [self.delegate labStockMainViewDidScrollToHead:self];
            }
            LABStockSafeBlock(^{ [self setNeedsDisplay]; });
            panEnable = NO;
            return;
        }
        NSInteger temp = self.drawPos.begin;
        self.drawPos.begin -= moveNum;
        if (self.drawPos.begin <= 0) {
            self.drawPos.begin = 0;
            moveNum = temp;
        }
        self.drawPos.endPos += moveNum;
        ///已经移动了translationX距离,减去移动条数的宽度,就是最开始的起始位置
        self.drawPos.xPosition -= moveNum * (lineGap+lineWidth);
    }else if (translationX < 0) {
        ///左滑,左移动
        if (self.drawPos.endPos <= 0) {
            if (!panEnable) {
                return;
            }
            ///到最右边了
            self.drawPos.xPosition = lineGap+lineWidth/2.0;
            ///通知代理
            if (self.delegateFlags.stockScrollToTailFlag) {
                [self.delegate labStockMainViewDidScrollToTail:self];
            }
            LABStockSafeBlock(^{ [self setNeedsDisplay]; });
            panEnable = NO;
            return;
        }
        if (self.drawPos.endPos - moveNum <= 0) {
            moveNum = self.drawPos.endPos;
        }
        self.drawPos.begin += moveNum;
        ///已经移动了translationX距离,加上移动条数的宽度,就是最开始的起始位置
        self.drawPos.xPosition += moveNum * (lineGap+lineWidth);
        ///一直滑动,通过重新绘图后,endPos可能会小于等于0,所以当下面条件成立时,重置偏移量,防止页面跳动
        if (self.drawPos.endPos <= 0) {
            self.drawPos.xPosition = lineGap+lineWidth/2.0;
        }
    }
    LABStockSafeBlock(^{ [self setNeedsDisplay]; });
}

///平移手势结束,x方向有速度时,循环调用来更新View
- (void)updateView:(CADisplayLink *)dis {
    currentCount ++;
    if (currentCount > updateCount || !panEnable) {
        ///当滑动计算的次数大于总次数或者标记到头不需要计算的时候,结束
        [dis removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [dis invalidate];
        [cacheDisArray removeObject:dis];
        if (cacheDisArray.count <= 0) {
            panEnable = YES;
        }
        dis = nil;
        CGFloat lineGap = [LABStockVariable lineGap];
        CGFloat lineWidth = [LABStockVariable lineWidth];
        self.drawPos.xPosition = lineGap+lineWidth/2.0;
        LABStockSafeBlock(^{ [self setNeedsDisplay]; });
    }else {
        CGFloat x = (CGFloat)velocity.x/currentCount/30;
        [self updateStockView:x];
    }
}

#pragma mark --getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [LABStockTimeLineMaskView new];
        _maskView.type = self.type;
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _maskView.hidden = YES;
    }
    return _maskView;
}

#pragma mark --手势操作

///缩放手势
static BOOL pinchEnable = YES;//标记手势是否还需要计算
- (void)event_pinchAction:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled || pinch.state == UIGestureRecognizerStateFailed) {
        pinchEnable = YES;
        return;
    }
    if (self.lineModels.count <= 0 || (self.maskView && !self.maskView.hidden) || !pinchEnable) {
        ///没有数据,遮罩没有隐藏或者手势不需要计算缩放,手势不触发
        return;
    }
    CGFloat lineGap = [LABStockVariable lineGap];
    CGFloat lineWidth = [LABStockVariable lineWidth];
    CGFloat oldLineWidth = lineWidth;
    ///1.获取缩放倍数
    static CGFloat oldScale = 1.0f;
    CGFloat difValue = pinch.scale - oldScale;
    if (ABS(difValue) > LABStockLineScaleBound) {
        ///缩放手势缩放绝对值大于缩放限制,则认为可以缩放
        if (pinch.numberOfTouches == 2) {
            ///2.计算新的宽度,按照缩放因子变化
            CGFloat newLineWidth = lineWidth * (difValue > 0 ? (1 + LABStockLineScaleFactor) : (1 - LABStockLineScaleFactor));
            [LABStockVariable setLineWith:newLineWidth];
            lineWidth = [LABStockVariable lineWidth];
            ///新宽度等于界限的宽度,则不能缩放了
            if (lineWidth == LABStockLineMaxWidth) {
                ///通知代理
                if (self.delegateFlags.stockDidScaleMaxFlag) {
                    [self.delegate labStockMainViewDidScaleMax:self];
                }
                pinchEnable = NO;
                return;
            }else if (oldLineWidth == LABStockLineMinWidth) {
                ///通知代理
                if (self.delegateFlags.stockDidScaleMinFlag) {
                    [self.delegate labStockMainViewDidScaleMin:self];
                }
                pinchEnable = NO;
                return;
            }
            ///3.计算显示数据的位置
            if (self.drawPos.endPos != 0) {//不在最新的位置,才需要计算
                NSInteger screenCount = CGRectGetWidth(self.frame)/(lineGap+lineWidth);
                ///以最后一个为基准缩放,即最后一个数据索引不变
                self.drawPos.begin = self.drawPos.end + 1 - screenCount;
                if (self.drawPos.begin < 0) {
                    self.drawPos.begin = 0;
                }
            }
            self.drawPos.xPosition = lineGap + lineWidth/2.0;
            LABStockSafeBlock(^{ [self setNeedsDisplay]; });
        }
    }
}

///长按手势
- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (self.lineModels.count <= 0) {
        ///没有数据不触发手势
        return;
    }
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        ///手势开始或者移动
        CGPoint location = [longPress locationInView:self];
        ///更新选中数据
        self.selectedModel = [self getRightModelByPoint:location];
        ///添加MaskView并显示
        self.maskView.hidden = NO;
        ///更新子View中选中数据的显示
        NSInteger selIndex = [self getIndexInDrawModelsByPoint:location];
        CGPoint p = [self.drawLinePositionModels[selIndex] CGPointValue];
        CGPoint p1 = CGPointMake(p.x, p.y+LABStockScrollViewTopGap);
        [self.maskView updateSelectModel:self.selectedModel positionPoint:p1 stockTimePositionY:CGRectGetMinY(self.timeView.frame)];
        [self.timeLineView updateSelectIndex:self.selectIndex];
        [self.volumeView updateSelectIndex:self.selectIndex];
        [self.accessoryView updateSelectIndex:self.selectIndex];
        ///通知长按
        if (self.delegateFlags.stockLongPressFlag) {
            [self.delegate labStockMainView:self longPressSelectedModel:self.selectedModel];
        }
    }else if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        ///手势结束,取消或者失败
        self.maskView.hidden = YES;
        ///长按取消
        if (self.delegateFlags.stockLongPressFlag) {
            [self.delegate labStockMainView:self longPressSelectedModel:nil];
        }
        LABStockSafeBlock(^{ [self setNeedsDisplay]; });
    }
}

///平移手势
static BOOL panEnable = YES;//标记手势是否还需要计算
static NSMutableArray *cacheDisArray;//保存CADisplayLink对象
- (void)event_panAction:(UIPanGestureRecognizer *)pan {
    if (self.lineModels.count <= 0 || (self.maskView && !self.maskView.hidden) || !self.panCanMove) {
        ///没有数据,遮罩未隐藏,手势标记不可用或者手势到头不需要计算,不触发手势
        return;
    }
    ///记录上一次的点
    static CGPoint prePoint;
    ///记录移动的距离
    static CGFloat translationX;
    CGPoint locationPoint = [pan locationInView:self];
    if(UIGestureRecognizerStateBegan == pan.state) {
        prePoint = locationPoint;
        translationX = 0.0f;
    }else if (UIGestureRecognizerStateChanged == pan.state) {
        if (!panEnable) {
            return;
        }
        translationX = (locationPoint.x - prePoint.x);
        [pan setTranslation:CGPointZero inView:self];
        prePoint = locationPoint;
        [self updateStockView:translationX];
    }else if(pan.state == UIGestureRecognizerStateEnded) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cacheDisArray = [NSMutableArray array];
        });
        ///手势结束减速滑动
        velocity = [pan velocityInView:self];
        CGFloat slideMult = velocity.x / velocityX;
        updateCount = ABS(slideMult) * 60 + 1;
        currentCount = 0;
        CADisplayLink *dis = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateView:)];
        [dis addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [cacheDisArray addObject:dis];
    }else if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        ///手势取消或者失败
        prePoint = CGPointZero;
        translationX = 0.0f;
        CGFloat lineGap = [LABStockVariable lineGap];
        CGFloat lineWidth = [LABStockVariable lineWidth];
        self.drawPos.xPosition = lineGap+lineWidth/2.0;
        panEnable = YES;
        LABStockSafeBlock(^{ [self setNeedsDisplay]; });
    }
}

#pragma mark --UIGestureRecognizerDelegate
///处理手势冲突问题,平移手势和其父类的平移手势冲突,左右滑动则不能穿透,只有自己响应,上下滑动可以穿透,自己标记不响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        self.panCanMove = YES;
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan: {
                UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
                CGPoint velocity = [pan velocityInView:self];
                CGFloat Vx = fabs(velocity.x);
                CGFloat Vy = fabs(velocity.y);
                if (Vx < Vy) {
                    ///上下滑动,可以穿透,同时触发
                    self.panCanMove = NO;
                    return YES;
                }
                return NO;
            }
                break;
            case UIGestureRecognizerStateChanged:
                return NO;
                break;
            default:
                break;
        }
    }
    return NO;
}

@end
