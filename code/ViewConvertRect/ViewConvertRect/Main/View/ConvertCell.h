//
//  ConvertCell.h
//  ViewConvertRect
//
//  Created by darkwing90s on 2019/7/21.
//  Copyright © 2019 www.devpeng.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ConvertCellDelegate <NSObject>

- (void)convertCellDelegateBtnDown:(UIButton *)btn;

@end

@interface ConvertCell : UITableViewCell

@property (nonatomic, weak) id<ConvertCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
