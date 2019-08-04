//
//  NSString+CTURL.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/14.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSString+CTURL.h"

@implementation NSString (CTURL)

- (NSDictionary *)ct_URLQueryParams
{
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *components = [self componentsSeparatedByString:@"&"];
    [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSArray *param = [obj componentsSeparatedByString:@"="];
            if ([param count] == 2) {
                NSString *key = param[0];
                NSString *encodedValue = param[1];
                
                NSString *decodeString = [encodedValue stringByRemovingPercentEncoding];
                resultDictionary[key] = decodeString;
            }
        }
    }];
    return resultDictionary;
}

@end
