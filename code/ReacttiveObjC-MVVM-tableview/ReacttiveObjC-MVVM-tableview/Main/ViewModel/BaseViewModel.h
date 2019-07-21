//
//  BaseViewModel.h
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/21.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : NSObject

@property (nonatomic) RACSubject *errors;

/**
 *  取消请求Command
 */
@property (nonatomic, strong, readonly) RACCommand *cancelCommand;


@end

NS_ASSUME_NONNULL_END
