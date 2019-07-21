//
//  MainModel.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel

+ (instancetype)mainModelWithDic:(NSDictionary *)dic
{
    MainModel *model = [[MainModel alloc] init];
    model.rtTitle = dic[@"title"];
    model.rtSelect = dic[@"select"];
    
    return model;
}

@end
