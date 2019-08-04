//
//  NSString+CTHeight.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSString+CTHeight.h"

@implementation NSString (CTHeight)

- (CGFloat)ct_heightWithFont:(UIFont *)font width:(CGFloat)width
{
    CGSize constrainSize = CGSizeMake(width, CGFLOAT_MAX);
    CGRect rect = [self boundingRectWithSize:constrainSize
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    return rect.size.height;
}

@end
