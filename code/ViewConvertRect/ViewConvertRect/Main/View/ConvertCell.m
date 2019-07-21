//
//  ConvertCell.m
//  ViewConvertRect
//
//  Created by darkwing90s on 2019/7/21.
//  Copyright © 2019 www.devpeng.com. All rights reserved.
//

#import "ConvertCell.h"

@implementation ConvertCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)convertBtnDwon:(UIButton *)button {
    
//    UIButton *button = (UIButton *)sender;

    button.tag = self.tag;
    
    NSLog(@"convertBtnDwon-Cell:%@",NSStringFromCGRect(button.frame));
    if (self.delegate && [self.delegate respondsToSelector:@selector(convertCellDelegateBtnDown:)]) {
        [self.delegate convertCellDelegateBtnDown:button];
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    // 计算viewB上的viewC相对于viewA的frame。
    // 计算self（当前cell）上的控件button的frame相对于window的frame
    CGRect rect = [self convertRect:button.frame toView:window];
    NSLog(@"convertToView-Cell:%@",NSStringFromCGRect(rect));
    
}

@end
