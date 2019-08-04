//
//  NSString+CTHash.h
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CTHash)

- (NSData *)ct_MD5;
- (NSString *)ct_MD5String;

@end
