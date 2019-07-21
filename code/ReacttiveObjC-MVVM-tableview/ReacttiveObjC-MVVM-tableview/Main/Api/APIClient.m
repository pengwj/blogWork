//
//  APIClient.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "APIClient.h"
#import "MainModel.h"

@implementation APIClient

static APIClient *apiClient = nil;
+ (APIClient *)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiClient = [[APIClient alloc] init];
    });
    return apiClient;
}

// 模拟网络请求
- (RACSignal *)fetchProductWithPageIndex:(NSUInteger)pageIndex
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self doRequestMethodPageIndex:pageIndex success:^(id responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            
            [subscriber sendNext:responseDict];
            [subscriber sendCompleted];
            
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] doNext:^(id x) {
        
    }];
}

// 模拟数据
- (void)doRequestMethodPageIndex:(NSUInteger)pageIndex success:(void (^)(id))success
                failure:(void (^)(NSError *))failure
{
    
    NSUInteger index = arc4random_uniform(1);

    if (index == 0) {
        
        NSUInteger code = arc4random_uniform(1);

        NSDictionary *responseDict = @{@"code":@(code),
                                       @"info":@[@{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+1,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+2,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+3,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+4,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+5,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+6,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+7,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+8,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+9,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+10,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+11,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+12,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+13,arc4random()%100],@"select":@"0"},
                                                 @{@"title":[NSString stringWithFormat:@"序号：%ld   随机数：%u",pageIndex*15+14,arc4random()%100],@"select":@"0"}]
                                       };
        success(responseDict);
        
    } else {
        NSError *error = [NSError new];
        failure(error);
    }
}

@end
