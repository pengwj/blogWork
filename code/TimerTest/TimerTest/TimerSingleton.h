//
//  TimerSingleton.h
//  TimerTest
//
//  Created by Admin on 2019/7/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimerSingleton : NSObject

+ (TimerSingleton *)shareInstance;
- (void)finishedTimer;

@end

NS_ASSUME_NONNULL_END
