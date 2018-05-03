//
//  ViewController.m
//  QBanner
//
//  Created by lijingjing on 17/08/2017.
//  Copyright © 2017 LeoQ. All rights reserved.
//

#import "ViewController.h"
#import "QBanner.h"
@interface ViewController ()
@property(nonatomic, weak) QBanner *banner;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    NSMutableArray *imgs = [@[] mutableCopy];
    for (int i = 0; i < 5; i ++) {
        [imgs addObject:[UIImage imageNamed:[@(i) stringValue]]];
    }
    self.banner.images = imgs;
    
    
    
    UISegmentedControl *seg = [[UISegmentedControl alloc]initWithItems:@[@"无",@"左大",@"中大",@"右大",@"视差"]];
    seg.frame = CGRectMake(20, CGRectGetMaxY(self.banner.frame)+20, CGRectGetWidth(self.view.bounds)-40, 40);
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];
    
    
    UISwitch *sw = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    sw.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetMaxY(seg.frame)+30);
    [sw addTarget:self action:@selector(swClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sw];
    
    UISlider *sl = [[UISlider alloc]init];
    sl.maximumValue = 2;
    sl.minimumValue = 0;
    sl.frame = CGRectMake(20, CGRectGetMaxY(sw.frame)+20, CGRectGetWidth(self.view.bounds)-40, 20);
    [sl addTarget:self action:@selector(slChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sl];
}
- (QBanner *)banner{
    if (!_banner) {
        
        QBanner *banner = [[QBanner alloc]init];
        banner.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)/(16/9.f));
        banner.animationStyle = QBannerAnimateStyleNone;
        banner.duration = 10;
        [self.view addSubview:banner];
        _banner = banner;
    }
    return _banner;
}
- (void)slChanged:(UISlider *)sl{
    self.banner.parallaxOffsetRatio = sl.value;
    
    self.banner.duration = sl.value;
}
- (void)swClick:(UISwitch *)sw{
    self.banner.autoScrolling = sw.on;
}
- (void)segClick:(UISegmentedControl *)seg{
    self.banner.animationStyle = seg.selectedSegmentIndex;
//    [self.banner reload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
