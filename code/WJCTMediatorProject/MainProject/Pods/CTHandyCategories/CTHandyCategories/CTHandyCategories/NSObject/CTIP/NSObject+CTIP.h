//
//  NSObject+CTIP.h
//  CTHandyCategories
//
//  Created by casa on 2018/3/14.
//  Copyright © 2018年 casa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CTIP)

- (NSString *)ct_ipAddressWithShouldPreferIPv4:(BOOL)preferIPv4;

@end
