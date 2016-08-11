//
//  ViewController.m
//  TimeSliderViewDemo
//
//  Created by 方常伟 on 16/8/8.
//  Copyright © 2016年 方常伟. All rights reserved.
//

#import "ViewController.h"
#import "TimeSliderView.h"
#import "UIViewAdditions.h"


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<TimeSliderProtocol>
@property (nonatomic, strong) TimeSliderView* timeSliderView;
@property (nonatomic, strong)NSArray * hisBlockArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeSliderView = [[TimeSliderView alloc]initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 110)];
    self.timeSliderView.timeDelegate = self;
    self.timeSliderView.currentTime = [NSDate date];
    
    self.hisBlockArray = @[@"2016-08-11 00:30:03",
                           @"2016-08-11 04:59:03",
                           @"2016-08-11 09:30:03",
                           @"2016-08-11 15:59:03",
                           @"2016-08-11 17:00:03",
                           @"2016-08-11 17:30:03"];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *str  in self.hisBlockArray) {
        
        NSDate * date = [self dateformString:str];
        
        [arr addObject:date];
    }
    self.timeSliderView.hisBlockArray = arr;
    [self.view addSubview:_timeSliderView];
    [self.timeSliderView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.timeSliderView addObserver:self forKeyPath:@"isTimeDragging" options:NSKeyValueObservingOptionNew context:nil];
}
- (NSDate *)dateformString:(NSString *)dateStr{
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromdate=[format dateFromString:dateStr];
    return fromdate;
}
-(void)onTimeSliderSelectedTime:(NSDate *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSLog(@"time-- %@", [formatter stringFromDate:time]);

}
#pragma mark - 拖动显示时间
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]&&self.timeSliderView.isDragging) {
        [self showDate:[self.timeSliderView getDateForOffset]];
    }
    if ([keyPath isEqualToString:@"isTimeDragging"]&&!self.timeSliderView.isTimeDragging) {
        [timeshow removeFromSuperview];
        timeshow = nil;
    }
}

static UILabel *timeshow = nil;

- (void)showDate:(NSDate *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (!timeshow) {
        timeshow = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80, 150, 160, 40)];
        timeshow.textAlignment = NSTextAlignmentCenter;
        timeshow.textColor = [UIColor whiteColor];
        timeshow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        timeshow.font = [UIFont systemFontOfSize:15];
        timeshow.clipsToBounds = YES;
        timeshow.layer.cornerRadius = 5;
        [[UIApplication sharedApplication].keyWindow addSubview:timeshow];
    }
    timeshow.text = [formatter stringFromDate:time];
}


-(void)dealloc{
    [self.timeSliderView removeObserver:self forKeyPath:@"contentOffset"];
    [self.timeSliderView removeObserver:self forKeyPath:@"isTimeDragging"];
}
@end
