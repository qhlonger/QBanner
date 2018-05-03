
//
//  QBanner.m
//  QKit
//
//  Created by lijingjing on 29/08/2017.
//  Copyright © 2017 KMax. All rights reserved.
//

#import "QBanner.h"

@interface QBanner ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSInteger sections;
@property(nonatomic, assign) CGFloat currentPage;
@property(nonatomic, assign) NSInteger itemCount;
@end
@implementation QBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doAddSubview];
        [self doInitVar];
        
    }
    return self;
}
- (void)layoutSubviews{
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-20, CGRectGetWidth(self.bounds), 20);
}
- (void)doInitVar{
    self.autoScrolling = YES;
    self.itemCount = 0;
    self.sections = 100;
    self.currentPage = 0;
    self.animationStyle = QBannerAnimateStyleParallax;
    self.parallaxOffsetRatio = 1;
    
    
    self.duration = 3;
}

- (void)doAddSubview{
    [self collectionView];
    [self pageControl];
}
- (void)reload{
    if(self.numberOfItem)
        self.itemCount = self.numberOfItem(self);
    
    if(self.images)
        self.itemCount = self.images.count;
    
    [self.collectionView reloadData];
    [self doUpdateCell];
}
- (void)setAnimationStyle:(QBannerAnimateStyle)animationStyle{
    _animationStyle = animationStyle;
    [self doUpdateCell];
}
- (void)setParallaxOffsetRatio:(CGFloat)parallaxOffsetRatio{
    _parallaxOffsetRatio = parallaxOffsetRatio;
    [self doUpdateCell];
}
- (void)setNumberOfItem:(NSInteger (^)(QBanner *))numberOfItem{
    _numberOfItem = numberOfItem;
}
- (void)setItemCount:(NSInteger)itemCount{
    _itemCount = itemCount;
    self.pageControl.numberOfPages = itemCount;
    if(self.itemCount <= 1){
        self.autoScrolling = NO;
    }
}
- (void)setCurrentPage:(CGFloat)currentPage{
    _currentPage = currentPage;
    self.pageControl.currentPage = (NSInteger)currentPage;
}
- (void)setImages:(NSArray *)images{
    _images = images;
    self.itemCount = images.count;
    [self.collectionView reloadData];
    self.autoScrolling = self.itemCount > 1;
    [self doUpdateCell];
}

- (void)setDuration:(NSTimeInterval)duration{
    _duration = duration;
    
    [self stopTimer];
    
    self.timer = [QBannerHelper scheduledTimerWithTimeInterval:duration target:self selector:@selector(toNext) userInfo:nil];
    if(!self.autoScrolling)
       [self pauseTimer];
}

- (void)setAutoScrolling:(BOOL)autoScrolling{
    if(autoScrolling && !self.autoScrolling){
        [self startTimer];
    }else if(!autoScrolling && self.autoScrolling){
        [self pauseTimer];
    }
    _autoScrolling = autoScrolling;
    
}
- (void)toNext{
    if(self.itemCount <= 1){
        return;
        
    }
    
    NSIndexPath *currentIdxPath = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    NSInteger nextItem, nextSection;
    if(currentIdxPath.section >= self.sections - 1){
        nextSection = self.sections/2;
    }else{
        nextSection = currentIdxPath.section;
    }
    
    if(currentIdxPath.item >= self.itemCount - 1){
        nextItem = 0;
        nextSection = currentIdxPath.section+1;
    }else{
        nextItem = currentIdxPath.item+1;
    }
    NSIndexPath *nextIdxPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    [self.collectionView scrollToItemAtIndexPath:nextIdxPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}
- (void)pauseTimer{
    [self.timer setFireDate:[NSDate distantFuture]];
    _autoScrolling = NO;
}
- (void)stopTimer{
    [self.timer invalidate];
    _autoScrolling = NO;
}
- (void)startTimer{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = interval ;
    NSNumber *stamp = [NSNumber numberWithLongLong:totalMilliseconds];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[stamp longLongValue] + 5];
    [self.timer setFireDate:date];
    _autoScrolling = YES;
}
- (UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc]init];
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}
static NSString *QBannerCellID = @"QBannerCell";
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionView *collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            [collectionView registerClass:[QBannerCell class] forCellWithReuseIdentifier:QBannerCellID];
            collectionView.alwaysBounceHorizontal = YES;
            [self addSubview:collectionView];
            collectionView;
        });
        _collectionView = collectionView;
    }
    return _collectionView;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.autoScrolling)
        [self pauseTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(self.autoScrolling)
        [self startTimer];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.didSelectAtIndex)self.didSelectAtIndex(indexPath.row);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.itemCount > 1 ? self.sections : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemCount;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.frame.size;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QBannerCellID forIndexPath:indexPath];
    cell.animationStyle = self.animationStyle;
    cell.parallaxOffsetRatio = self.parallaxOffsetRatio;
    
    if(self.images.count > indexPath.row ){
        id img = self.images[indexPath.item];
        if ([img isKindOfClass:[UIImage class]]) {
            cell.iconView.image = img;
        }
    }
    
    if(self.customerCellForItem)self.customerCellForItem(cell, indexPath.item);
    cell.customSetRatio = self.customSetRatio;\
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.itemCount > 1){
        if (scrollView.contentOffset.x <= self.itemCount * CGRectGetWidth(self.frame) * self.sections*0.1) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.sections*0.5] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }else if(scrollView.contentOffset.x >= self.itemCount * CGRectGetWidth(self.frame) * self.sections*0.9) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.sections*0.5] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            
        }
    }
    [self doUpdateCell];
    [self calCurrentPage];
}
- (void)doUpdateCell{
        CGFloat minX = -CGRectGetWidth(self.collectionView.bounds);
        CGFloat maxX = CGRectGetWidth(self.collectionView.bounds)*2;
        for (QBannerCell *cell in self.collectionView.visibleCells) {
            cell.animationStyle = self.animationStyle;
            cell.parallaxOffsetRatio = self.parallaxOffsetRatio;
            
            if(self.animationStyle == QBannerAnimateStyleNone){
                cell.ratio = 1;
                continue;
            }
            CGRect rect = [self.collectionView convertRect:cell.frame toView:self];
            CGFloat midX = CGRectGetMidX(rect);
            //x=0-1
            CGFloat ratio = [QBannerHelper getRatioWithMax:maxX min:minX mid:midX];
            CGFloat finalRatio = ratio;
            if(self.animationStyle == QBannerAnimateStyleScaleL){
                //1.5-1-0.5
                finalRatio = 2 - ratio - 0.5;
            }else if(self.animationStyle == QBannerAnimateStyleScaleM){
                //0.5-1-0.5
                finalRatio = (sin(M_PI * ratio)) / 2 + 0.5;
            }else if(self.animationStyle == QBannerAnimateStyleScaleR){
                //0.5-1-1.5
                finalRatio =ratio + 0.5;
            }else if(self.animationStyle == QBannerAnimateStyleParallax){
                
            }
            cell.ratio = finalRatio;
        }
    
    
}
- (void)calCurrentPage{
    NSIndexPath *currentIdxPath = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    CGPoint offset = self.collectionView.contentOffset;
    CGFloat offsetX = offset.x;
    while (offsetX > CGRectGetWidth(self.collectionView.bounds)) {
        offsetX -= CGRectGetWidth(self.collectionView.bounds);
    }
    
    //    CGFloat ratio = offsetX/CGRectGetWidth(self.collectionView.bounds);
    self.currentPage = currentIdxPath.row;
}

@end

#pragma mark - BannerCell
@implementation QBannerCell

- (void)initCell{
//    self.bannerContentView.frame = self.bounds;
//    self.iconView.frame = self.bannerContentView.bounds;
//
//    self.bannerContentView.transform  = CGAffineTransformMakeScale(1, 1);
    
    [self setRatio:self.ratio];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self doAddSubview];
        [self doInitVar];
    }
    return self;
}
//- (void)prepareForReuse{
//    [self initCell];
//}
- (UILabel *)label{
    if (!_label) {
        UILabel *label = [[UILabel alloc]init];
        label.frame = self.bounds;
        [self.contentView addSubview:label];
        _label = label;
    }
    return _label;
}
- (void)doAddSubview{
    [self bannerContentView];
    [self iconView];
    [self label];
}
- (void)doInitVar{
    
    self.ratio = 1;
    self.parallaxOffsetRatio = 1;
    
    self.bannerContentView.frame = self.bounds;
    self.iconView.frame = self.bannerContentView.bounds;
    
//    self.bannerContentView.transform  = CGAffineTransformMakeScale(1, 1);
    self.clipsToBounds = YES;
    self.contentView.clipsToBounds = YES;
}
//- (void)setAnimationStyle:(QBannerAnimateStyle)animationStyle{
//    _animationStyle = animationStyle;
//
//}
- (void)setRatio:(CGFloat)ratio{
    _ratio = ratio;
//    self.label.text = [NSString stringWithFormat:@"%f",ratio];
    NSLog(@"%f",ratio);
    if(self.customSetRatio){
        self.customSetRatio(self, ratio);
    }else{
        switch (self.animationStyle) {
            case QBannerAnimateStyleParallax:{
                if(ratio > 1 || ratio < 0)return;
                CGFloat lw = CGRectGetWidth(self.iconView.bounds)*1.5 * self.parallaxOffsetRatio;
                self.bannerContentView.frame =
                [QBannerHelper getRectWithMaxRect:CGRectMake(-lw,
                                                             0,
                                                             self.frame.size.width,
                                                             self.frame.size.height)
                                          minRect:CGRectMake(lw,
                                                             0,
                                                             self.frame.size.width,
                                                             self.frame.size.height)
                                            Ratio:ratio];
                self.iconView.frame = self.bannerContentView.bounds;
            }break;
            case QBannerAnimateStyleNone:{
                
                self.bannerContentView.frame = self.bounds;
                self.iconView.frame = self.bannerContentView.bounds;
                
            }break;
            default:{
                self.bannerContentView.frame =
                [QBannerHelper getRectWithMaxRect:CGRectMake(0,
                                                             0,
                                                             self.frame.size.width ,
                                                             self.frame.size.height )
                                          minRect:CGRectMake(0,
                                                             0,
                                                             self.frame.size.width * 0.2,
                                                             self.frame.size.height * 0.2)
                                            Ratio:ratio];
                self.bannerContentView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
                self.iconView.frame = self.bannerContentView.bounds;
            }break;
        }
        
        
        
    }
}
- (UIImageView *)iconView{
    if (!_iconView) {
        UIImageView *icon = ({
            icon = [[UIImageView alloc]init];
            icon.contentMode = UIViewContentModeScaleAspectFill;
            icon.clipsToBounds = YES;
            [self.bannerContentView addSubview:icon];
            icon;
        });
        _iconView = icon;
    }
    return _iconView;
}
- (UIView *)bannerContentView{
    if (!_bannerContentView) {
        UIView *bannerContentView = [[UIView alloc]init];
        [self.contentView addSubview:bannerContentView];
        _bannerContentView = bannerContentView;
    }
    return _bannerContentView;
}
@end

#pragma mark - Timer
@implementation QBannerTimer
- (void)timerTargetAction:(NSTimer *)timer{
    if (self.target) {
        IMP imp = [self.target methodForSelector:self.selector];
        void (*func)(id, SEL, NSTimer*) = (void *)imp;
        func(self.target, self.selector, timer);
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
#pragma mark - Helper
@implementation QBannerHelper

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo{
    QBannerTimer *timerTarget = [[QBannerTimer alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti target:timerTarget selector:@selector(timerTargetAction:) userInfo:userInfo repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    timerTarget.timer = timer;
    return timerTarget.timer;
}



/**
 根据最大值，最小值，中间值获取比例
 
 @param max 最大值
 @param min 最小值
 @param mid 中间值
 @return 比例
 */
+ (CGFloat)getRatioWithMax:(CGFloat)max min:(CGFloat)min mid:(CGFloat)mid{
    return (mid - min) / (max - min);
}

/**
 根据最大 最小 比例 获取 中间值
 
 @param max   最大
 @param min   最小
 @param ratio 比例
 
 @return 中间值
 */
+ (CGFloat)getMidWithMax:(CGFloat)max min:(CGFloat)min ratio:(CGFloat)ratio{
    return (max - min) * ratio + min;
}

/**
 根据最大rect，最小rect，比例获取中间rect
 
 @param maxRect 最大rect
 @param minRect 最小rect
 @param ratio 比例
 @return 中间rect
 */
+ (CGRect)getRectWithMaxRect:(CGRect)maxRect minRect:(CGRect)minRect Ratio:(CGFloat)ratio{
    return CGRectMake([QBannerHelper getMidWithMax:maxRect.origin.x       min:minRect.origin.x    ratio:ratio],
                      [QBannerHelper getMidWithMax:maxRect.origin.y       min:minRect.origin.y    ratio:ratio],
                      [QBannerHelper getMidWithMax:maxRect.size.width     min:minRect.size.width  ratio:ratio],
                      [QBannerHelper getMidWithMax:maxRect.size.height    min:minRect.size.height ratio:ratio]);
}

@end