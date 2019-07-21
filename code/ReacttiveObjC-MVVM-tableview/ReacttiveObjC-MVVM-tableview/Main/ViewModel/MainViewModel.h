//
//  MainViewModel.h
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewModel : BaseViewModel

@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 *  获取数据Command
 */
@property (nonatomic, strong, readonly) RACCommand *fetchProductCommand;

/**
 *  获取更多数据
 */
@property (nonatomic, strong, readonly) RACCommand *fetchMoreProductCommand;




@end

NS_ASSUME_NONNULL_END
