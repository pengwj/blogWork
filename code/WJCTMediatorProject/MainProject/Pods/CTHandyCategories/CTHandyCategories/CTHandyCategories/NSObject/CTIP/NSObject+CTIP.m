//
//  NSObject+CTIP.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/14.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSObject+CTIP.h"
#include <net/if.h>
#import <ifaddrs.h>
#include <arpa/inet.h>

#define IOS_CELLULAR    @"pdp_ip0"

#define IOS_WIFI_0      @"en0"
#define IOS_WIFI_1      @"en1"

#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation NSObject (CTIP)

- (NSString *)ct_ipAddressWithShouldPreferIPv4:(BOOL)preferIPv4
{
#if DEBUG
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/
      IOS_WIFI_0 @"/" IP_ADDR_IPv4,
      IOS_WIFI_0 @"/" IP_ADDR_IPv6,
      IOS_WIFI_1 @"/" IP_ADDR_IPv4,
      IOS_WIFI_1 @"/" IP_ADDR_IPv6,
      IOS_CELLULAR @"/" IP_ADDR_IPv4,
      IOS_CELLULAR @"/" IP_ADDR_IPv6
      ]
    :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/
      IOS_WIFI_0 @"/" IP_ADDR_IPv6,
      IOS_WIFI_0 @"/" IP_ADDR_IPv4,
      IOS_WIFI_1 @"/" IP_ADDR_IPv6,
      IOS_WIFI_1 @"/" IP_ADDR_IPv4,
      IOS_CELLULAR @"/" IP_ADDR_IPv6,
      IOS_CELLULAR @"/" IP_ADDR_IPv4
      ];
    
    NSDictionary *addresses = [self ipAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop){
        address = addresses[key];
        if(address) *stop = YES;
    }];
    return address ? address : @"0.0.0.0";
#else
    return nil;
#endif
}

- (NSDictionary *)ipAddresses
{
#if DEBUG
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
#else
    return nil;
#endif
}

@end
