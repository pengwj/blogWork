//
//  BaseViewModel.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/21.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "BaseViewModel.h"

@implementation BaseViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _errors = [RACSubject subject];
        
        _cancelCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal empty];
        }];
    }
    
    return self;
}

- (void)dealloc {
    [_errors sendCompleted];
}

@end
