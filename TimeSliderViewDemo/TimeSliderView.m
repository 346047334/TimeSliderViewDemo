//
//  TimeSliderView.m
//  ulucuMainUI
//
//  Created by 申志远 on 15/7/16.
//  Copyright (c) 2015年 ulucu. All rights reserved.
//

#import "TimeSliderView.h"
#import "ULCUIColor-Expanded.h"
#import "UIViewAdditions.h"
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
static CGFloat TimeImageViewLenght  = 0.0f;
static CGFloat step                 = 5.0;
static int salce                    = 1.0;
@interface TimeSliderView ()
@property (nonatomic,strong) TimeView *timeView;
@property (nonatomic,strong) UIImageView *tipImageView;
 @end



@implementation TimeSliderView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithRGBHex:0xf0f0f0].CGColor;
        self.layer.borderWidth = 1;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        salce = 1;
        TimeImageViewLenght = 24*10*salce*step;
        self.timeView = [[TimeView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - 30.0, 0, TimeImageViewLenght, self.height)];

        [self addSubview:self.timeView];
        [self addSubview:self.tipImageView];
        self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDouble)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];//双击改变时间轴比例
    }
    return self;
}

-(UIImageView *)tipImageView{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tipiamge"]];
        self.tipImageView.frame = CGRectMake(SCREEN_WIDTH/2-7, 30, 14, self.height-30);
    }
    return _tipImageView;
}
- (void)awakeFromNib{
    self.layer.borderColor = [UIColor colorWithRGBHex:0xf0f0f0].CGColor;
    self.layer.borderWidth = 1;
    self.delegate = self;
    salce = 1;
    TimeImageViewLenght = 24*10*salce*step;
    self.timeView = [[TimeView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - 30.0, 0, TimeImageViewLenght, self.height)];
    [self addSubview:self.timeView];
    self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDouble)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
    NSLog(@"size:%@", NSStringFromCGSize(self.contentSize));
}

- (void)showDouble{
    self.isShowDoubleTime = !self.isShowDoubleTime;
}

- (void)setHisBlockArray:(NSArray *)hisBlockArray{
    _hisBlockArray = hisBlockArray;
    
    self.timeView.hisBlockArray = _hisBlockArray;
}

- (void)setIsShowDoubleTime:(BOOL)isShowDoubleTime{
    _isShowDoubleTime = isShowDoubleTime;
    if (isShowDoubleTime) {
        salce = 6;
    }else{
        salce = 1;
    }
    TimeImageViewLenght = 24*10*salce*step;
    self.contentSize = CGSizeMake(SCREEN_WIDTH  + TimeImageViewLenght, self.height);
    [self.timeView setNeedsLayout];
    [self.timeView setNeedsDisplay];
    [self updateOffset];
    
}

- (void)setCurrentTime:(NSDate *)currentTime{
    if (self.isTimeDragging) {
        return ;
    }
    _currentTime = currentTime;
    self.timeView.currentDate = self.currentTime;
    [self updateOffset];
}

-(void)updateOffset{
    [self setOffsetForDate:self.currentTime];
}

#pragma mark - 根据时间设置offset
- (void)setOffsetForDate:(NSDate *)date{
    NSArray * dateArr = [self timeForDate:date];
    NSInteger  hour = [dateArr[0] integerValue];
    NSInteger  minute = [dateArr[1] integerValue];
    NSInteger  second = [dateArr[2] integerValue];
    CGFloat xOffset  = hour * hourOffset() + minute * minuteOffset() + second * secondOffset() ;
    [self setContentOffset:CGPointMake(xOffset, self.contentOffset.y) animated:YES];
}

- (CGFloat)maxOffset{
    NSInteger nowDate = [self zeroOfDate].timeIntervalSince1970;
    NSInteger current = self.currentTime.timeIntervalSince1970;
    if (nowDate > current) {
        return TimeImageViewLenght;
    }
    NSArray * timeArr = [self timeForDate:[NSDate date]];
    NSInteger  hour = [timeArr[0] integerValue];
    NSInteger  minute = [timeArr[1] integerValue];
    NSInteger  second = [timeArr[2] integerValue];
    CGFloat xOffset  = hour * hourOffset() + minute * minuteOffset() + second * secondOffset() ;
    return xOffset;
}

- (NSArray *)timeForDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *dateStr = [formatter stringFromDate:date];
    return [dateStr componentsSeparatedByString:@":"];
}

- (NSDate *)zeroOfDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(long int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}


#pragma mark - 根据offset获取时间
- (NSDate *)getDateForOffset{
    CGFloat xOffset =  self.contentOffset.x;
    if (xOffset < 0) {
        xOffset = 0;
    }
    if (xOffset > TimeImageViewLenght) {
        xOffset = TimeImageViewLenght;
    }
    NSInteger  hour = xOffset/hourOffset();
    hour %= 24;
    NSInteger  minute = xOffset/minuteOffset();
    minute %= 60;
    NSInteger second = xOffset/secondOffset();
    second %= 60;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formatter stringFromDate:self.currentTime];
    NSString *tempStr = [NSString stringWithFormat:@" %ld%ld:%ld%ld:%ld%ld",hour/10, hour%10, minute/10, minute%10,second/10, second%10];
    dateStr = [dateStr stringByAppendingString:tempStr];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:dateStr];
}

#pragma mark - offset/时间
CGFloat hourOffset(){
    return TimeImageViewLenght/24.0;
}

CGFloat minuteOffset(){
    return hourOffset()/60.0;
}
CGFloat secondOffset(){
    return minuteOffset()/60.0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isTimeDragging = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.tipImageView.frame = CGRectMake(SCREEN_WIDTH/2-7+scrollView.contentOffset.x, 30, 14, self.height-30);
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isTimeDragging = NO;
#if 1//如果滑动时间超过当前时间，将通过currentTime set方法重新设置为当前时间的偏移量
    if (self.contentOffset.x > [self maxOffset] || self.contentOffset.x < 0) {
        self.currentTime = [NSDate date];
        return ;
    }
#endif
    if ([self.timeDelegate respondsToSelector:@selector(onTimeSliderSelectedTime:)]) {
        NSDate *date = [self getDateForOffset];
        _currentTime = date;
        [self.timeDelegate onTimeSliderSelectedTime:date];
    }
}

@end

@implementation TimeView
/**
 *  构建时间所用数据
 */

const CGFloat hourlineHieght    =   16.0;
const CGFloat mintelineHieght   =   8.0;
const CGFloat hourlineWidth     =   1.0;
const CGFloat mintelineWidth    =   1.0;
const CGFloat fontSize          =   10.0;

const CGFloat offset            =   30.0;
const CGFloat distance          =   10.0;
const CGFloat dataHeight        =   80.0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, offset +24*10*salce*step + offset, frame.size.height);
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setHisBlockArray:(NSArray *)hisBlockArray
{
    _hisBlockArray = hisBlockArray;
    
    [self setNeedsDisplay];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, offset +24*10*salce*step + offset, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat hourY = fontSize + 2*distance;
    //数据域
    CGFloat dataY = hourY;
        // 灰色条
    CGContextSetFillColorWithColor(context, [UIColor colorWithRGBHex:0x999999].CGColor);
    CGRect dataRect = CGRectMake(offset, dataY, 24*10*salce*step , dataHeight);
    CGContextAddRect(context, dataRect);
    CGContextFillPath(context);
        // 有色区
    
    for (int i = 0 ; i < self.hisBlockArray.count/2; i++) {
        
        CGFloat start =  [self offsetForDate:self.hisBlockArray[i*2]];
        CGFloat end = [self offsetForDate:self.hisBlockArray[i*2 + 1]];
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithRGBHex:0x40b2a9].CGColor);
        CGRect dataRect = CGRectMake(start, dataY, end-start, dataHeight);
        CGContextAddRect(context, dataRect);
        CGContextFillPath(context);
    }
    
    //时间轴
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRGBHex:0xffffff].CGColor);
    for (int i = 0 ; i <= 24*10*salce; i++) {
        if (i%10) {
            CGContextSetLineWidth(context, mintelineWidth);
            CGContextMoveToPoint(context, offset + i*step, hourY);
            CGContextAddLineToPoint(context, offset + i*step, hourY + mintelineHieght);
            
            CGContextMoveToPoint(context, offset + i*step, hourY + dataHeight - mintelineHieght);
            CGContextAddLineToPoint(context, offset + i*step, hourY + dataHeight);
        }else{
            CGContextSetLineWidth(context, hourlineWidth);
            CGContextMoveToPoint(context, offset + i*step, hourY);
            CGContextAddLineToPoint(context, offset + i*step, hourY + hourlineHieght);
            
            CGContextMoveToPoint(context, offset + i*step, hourY + dataHeight - hourlineHieght);
            CGContextAddLineToPoint(context, offset + i*step, hourY + dataHeight);
        }
    }
    CGContextStrokePath(context);
    //时间点
    CGFloat timeY = /*(rect.size.height + hourlineWidth)/2.0 + */distance;
    for (int i = 0; i <= 24*salce; i++) {
        NSInteger hour = i*60/salce/60;
        NSInteger minute = i*60/salce%60;
        NSString *time = [NSString stringWithFormat:@"%.2d:%.2d",(int)hour,(int)minute];
        CGSize size = [time sizeWithAttributes:[self attributes]];
        CGPoint drawPoint = CGPointMake(offset + i*step*10 - size.width/2.0, timeY);
        [time drawAtPoint:drawPoint withAttributes:[self attributes]];
    }
}

- (NSDictionary *)attributes
{
    return @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
             NSForegroundColorAttributeName : [UIColor colorWithRGBHex:0x6d6d6d]};
}

- (CGFloat)offsetForDate:(NSDate *)date
{
    NSInteger time = [self timeForDate:date];
    return offset + step*24*10*salce*time/(24*60*60);
}

- (NSInteger)timeForDate:(NSDate *)date
{
    
    NSInteger timeInterval = date.timeIntervalSince1970 - self.currentDate.timeIntervalSince1970;
    if (timeInterval > 0) {
        return timeInterval;
    }else{
        return 0;
    }
}

- (void)setCurrentDate:(NSDate *)currentDate
{
    _currentDate = [currentDate copy];
    _currentDate = [self zeroOfDate:_currentDate];
}

- (NSDate *)zeroOfDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(long int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}
@end
