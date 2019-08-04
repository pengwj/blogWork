//
//  NSString+CTHash.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSString+CTHash.h"
#include <CommonCrypto/CommonDigest.h>
#import "NSData+CTHash.h"

@implementation NSString (CTHash)

- (NSData *)ct_MD5
{
    NSData *inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [inputData ct_MD5];
}

- (NSString *)ct_MD5String
{
    NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [inputData ct_MD5String];
}

@end
