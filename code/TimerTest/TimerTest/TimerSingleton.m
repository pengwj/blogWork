//
//  TimerSingleton.m
//  TimerTest
//
//  Created by Admin on 2019/7/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "TimerSingleton.h"
#import <UIKit/UIKit.h>

@interface TimerSingleton (){
//    dispatch_queue_t timerQueue;
}

@property (nonatomic, strong) dispatch_queue_t timeQueue;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat timerValue;

@end

@implementation TimerSingleton

static TimerSingleton *singleton = nil;
+ (TimerSingleton *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[TimerSingleton alloc] init];
    });
    
    [singleton addTimer];
    
    return singleton;
}

//懒加载创建子线程
- (dispatch_queue_t)timeQueue
{
    if (!_timeQueue) {
        _timeQueue = dispatch_queue_create("com.timer.test", DISPATCH_QUEUE_CONCURRENT);
    }
    return _timeQueue;
}

//添加定时器
- (void)addTimer
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.timeQueue, ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.timer) {
            strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDown) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:strongSelf.timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        //如果启动RunLoop的语句在实例化定时器之前，runloop中没有需要执行的任务，那么启动后RunLoop会自动停止。
        //所以runloop的启动需要放在添加定时器后

        }
        
    });

}

//执行任务
- (void)timerDown
{
    dispatch_async(dispatch_get_main_queue(), ^(){
    
        self.timerValue = self.timerValue+0.1;
        NSLog(@"timerValue:%0.2lf",self.timerValue);
        
    });
    
}

//定时器的停止
- (void)finishedTimer
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.timeQueue, ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.timerValue = 0.f;
        
        [strongSelf.timer invalidate];
        strongSelf.timer = nil;
    });
}

@end
