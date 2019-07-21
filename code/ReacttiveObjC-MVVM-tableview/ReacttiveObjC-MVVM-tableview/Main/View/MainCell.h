//
//  MainCell.h
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainModel;

NS_ASSUME_NONNULL_BEGIN

@interface MainCell : UITableViewCell

@property (nonatomic, strong) MainModel *model;

@end

NS_ASSUME_NONNULL_END
