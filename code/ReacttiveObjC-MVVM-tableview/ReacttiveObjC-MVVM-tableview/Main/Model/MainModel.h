//
//  MainModel.h
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainModel : NSObject

@property (nonatomic, copy) NSString *rtTitle;
@property (nonatomic, copy) NSString *rtSelect;

+ (instancetype)mainModelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
