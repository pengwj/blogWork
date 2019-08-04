//
//  NSString+CTDate.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/9.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSString+CTDate.h"

@implementation NSString (CTDate)

- (NSDate *)ct_dateFromRFC3339
{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    rfc3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSxxx";
//    rfc3339DateFormatter.timeZone = [NSTimeZone systemTimeZone];
//    rfc3339DateFormatter.locale = [NSLocale currentLocale];
    return [rfc3339DateFormatter dateFromString:self];
}

@end
