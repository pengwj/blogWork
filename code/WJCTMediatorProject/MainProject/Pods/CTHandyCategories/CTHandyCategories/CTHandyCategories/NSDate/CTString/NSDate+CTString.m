//
//  NSDate+CTString.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/9.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSDate+CTString.h"

@implementation NSDate (CTString)

- (NSString *)ct_stringWithyyyy_MM_dd_HH_mm_ss
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter stringFromDate:self];
}

@end
