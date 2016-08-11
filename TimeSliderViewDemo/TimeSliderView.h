//
//  TimeSliderView.h
//  ulucuMainUI
//
//  Created by 申志远 on 15/7/16.
//  Copyright (c) 2015年 ulucu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TimeSliderProtocol <NSObject>
-(void)onTimeSliderSelectedTime:(NSDate*)time;
@end

@interface TimeSliderView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic) NSDate *currentTime;         //当前时间
@property (weak) id<TimeSliderProtocol> timeDelegate;

@property (nonatomic) BOOL isTimeDragging;
@property (nonatomic, strong) NSArray *hisBlockArray;

- (NSDate *)getDateForOffset;

@property (nonatomic) BOOL isShowDoubleTime;//时间轴是否放大

@end



@interface TimeView : UIView

@property (nonatomic,copy) NSDate *currentDate;
@property (nonatomic, copy) NSArray *hisBlockArray;

@end