//
//  NSData+CTHash.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSData+CTHash.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSData (CTHash)

- (NSData *)ct_MD5
{
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (unsigned int)[self length], outputData);
    NSData *result = [NSData dataWithBytes:outputData length:CC_MD5_DIGEST_LENGTH];
    return result;
}

- (NSString *)ct_MD5String
{
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (unsigned int)[self length], outputData);
    
    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
        [hashStr appendFormat:@"%02x", outputData[i]];
    
    return hashStr;
}

@end
