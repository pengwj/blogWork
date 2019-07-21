//
//  MainViewModel.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "MainViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "APIClient.h"
#import "MainModel.h"

@interface MainViewModel ()

@property (nonatomic, assign) NSUInteger pageIndex;

@end

@implementation MainViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initCommed];
        [self initSubscribe];
        
    }
    return self;
}

- (void)initCommed
{
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    
    @weakify(self)
    _fetchProductCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.pageIndex = 0;
        return [[[APIClient sharedClient]
                        fetchProductWithPageIndex:self.pageIndex]
                        takeUntil:self.cancelCommand.executionSignals];
    }];
    
    _fetchMoreProductCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        self.pageIndex = self.pageIndex+1;
        return [[[APIClient sharedClient] fetchProductWithPageIndex:self.pageIndex] takeUntil:self.cancelCommand.executionSignals];
    }];
    
}

- (void)initSubscribe {
    
    @weakify(self);
    [[_fetchProductCommand.executionSignals switchToLatest] subscribeNext:^(id responseObject) {
        @strongify(self);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        
        NSInteger code = [[responseDict objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            
            NSArray *infoArray = [responseDict objectForKey:@"info"];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            
            [infoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic,NSUInteger idx,BOOL * _Nonnull stop){
                
                MainModel *model = [MainModel mainModelWithDic:dic];
                [tempArray addObject:model];
                
            }];

            /// ⚠️⚠️⚠️注意这里需要通过KVC的方式对数组进行操作
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArray.count, [tempArray count])];
            [[self mutableArrayValueForKey:@"dataArray"] insertObjects:tempArray atIndexes:indexSet];
            
        } else {
            
            [self.errors sendNext:[NSError new]];
        }

    }];
    
    [[_fetchMoreProductCommand.executionSignals switchToLatest] subscribeNext:^(id responseObject) {
        @strongify(self);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = [[responseDict objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            
            NSArray *infoArray = [responseDict objectForKey:@"info"];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];

            [infoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic,NSUInteger idx,BOOL * _Nonnull stop){
                
                MainModel *model = [MainModel mainModelWithDic:dic];
                [tempArray addObject:model];

            }];
            
            /// ⚠️⚠️⚠️注意这里需要通过KVC的方式对数组进行操作
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataArray.count, [tempArray count])];
            [[self mutableArrayValueForKey:@"dataArray"] insertObjects:tempArray atIndexes:indexSet];
            
        } else {
            
            [self.errors sendNext:[NSError new]];
        }
    }];
    
    [[RACSignal merge:@[_fetchProductCommand.errors, self.fetchMoreProductCommand.errors]] subscribe:self.errors];
}

@end
