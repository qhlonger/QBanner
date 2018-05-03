//
//  QBanner.h
//  QKit
//
//  Created by lijingjing on 29/08/2017.
//  Copyright © 2017 KMax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QBannerAnimateStyle) {
    //无
    QBannerAnimateStyleNone,
    //左大 右小
    QBannerAnimateStyleScaleL,
    //左小 中大 右小
    QBannerAnimateStyleScaleM,
    //左小 中大
    QBannerAnimateStyleScaleR,
    //视差
    QBannerAnimateStyleParallax,
};
@class QBannerCell;
@interface QBanner : UIView


/**
 setRatio时调用
 修改ratio时候,自定义cell,位置，大小缩放
 */
@property(nonatomic, copy) void(^customSetRatio) (QBannerCell *cell,CGFloat ratio);

/**
 滚动时候
 page改变,自定义pagecontrol
 */
@property(nonatomic, copy) void(^didScroll) (QBanner *banner,CGFloat page);
//@property(nonatomic, copy) void(^customer) *<#name#>

/**
 点击事件
 */
@property(nonatomic, copy) void(^didSelectAtIndex) (NSInteger index);

/**
 有多少item
 */
@property(nonatomic, copy) NSInteger (^numberOfItem)(QBanner *banner);

/**
 自定义cell
 */
@property(nonatomic, copy) void (^customerCellForItem)(QBannerCell *cell, NSInteger item);

/**
 可直接设置图片，或使用上方两个方法
 */
@property(nonatomic, strong) NSArray *images;

/**
 collectionView
 */
@property(nonatomic, weak) UICollectionView *collectionView;


/**
 自动滚动
 default:YES
 */
@property(nonatomic, assign) BOOL autoScrolling;

/**
 滚动间隔
 default:5
 */
@property(nonatomic, assign) NSTimeInterval duration;


/**
 pagecontrol
 */
@property(nonatomic, weak) UIPageControl *pageControl;

/**
 滚动动画样式
 default:None
 */
@property(nonatomic, assign) QBannerAnimateStyle animationStyle;


/**
 视差幅度
 
 建议取值范围[0,2]，
 
 取值在[0,2]范围内时
 1为图片不动，分割线动
 0为无视差 效果等于QBannerAnimateStyleNone，正常滚动
 2为聚合后打开
 取值越小时差越小
 取值越大视差越大
 
 
 取值为负数时，将会成为两个item间隔的宽度
 如：取值为1时，两个item刚好间隔一个item的宽度
 负数越小间隔越大
 
 取值在<-2 或 >2 时，很奇葩
 
 default:1
 */
@property(nonatomic, assign) CGFloat parallaxOffsetRatio;

/**
 重新加载
 */
- (void)reload;

/**
 暂停timer
 */
- (void)pauseTimer;

/**
 关闭timer
 */
- (void)stopTimer;

/**
 开启timer
 */
- (void)startTimer;
@end


@interface QBannerCell : UICollectionViewCell

@property(nonatomic, assign) CGFloat parallaxOffsetRatio;
@property(nonatomic, assign) CGFloat ratio;
@property(nonatomic, weak) UIImageView *iconView;
@property(nonatomic, weak) UIView *bannerContentView;
@property(nonatomic, weak) UILabel *label;
@property(nonatomic, copy) void(^customSetRatio) (QBannerCell *cell,CGFloat ratio);

@property(nonatomic, assign) QBannerAnimateStyle animationStyle;


- (void)initCell;
@end


@interface QBannerHelper : NSObject



+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo;
+ (CGFloat)getRatioWithMax:(CGFloat)max min:(CGFloat)min mid:(CGFloat)mid;
+ (CGFloat)getMidWithMax:(CGFloat)max min:(CGFloat)min ratio:(CGFloat)ratio;
+ (CGRect)getRectWithMaxRect:(CGRect)maxRect minRect:(CGRect)minRect Ratio:(CGFloat)ratio;

@end


@interface QBannerTimer : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;

- (void)timerTargetAction:(NSTimer *)timer;
@end


