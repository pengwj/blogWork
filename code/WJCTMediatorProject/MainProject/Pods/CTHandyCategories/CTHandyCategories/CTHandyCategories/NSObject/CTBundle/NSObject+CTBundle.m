//
//  NSObject+CTBundle.m
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "NSObject+CTBundle.h"

@interface CTBundleCache : NSObject

@property (nonatomic, strong) NSCache *cache;
+ (instancetype)sharedInstance;

@end

@implementation CTBundleCache

+ (instancetype)sharedInstance
{
    static CTBundleCache *bundleCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleCache = [[CTBundleCache alloc] init];
    });
    return bundleCache;
}

#pragma mark - getters and setters
- (NSCache *)cache
{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 10;
    }
    return _cache;
}

@end

@implementation NSObject (CTBundle)

- (NSBundle *)ct_bundleWithName:(NSString *)bundleName shouldReturnMainBundleIfBundleNotFound:(BOOL)shouldReturnMainBundleIfBundleNotFound
{
    NSBundle *bundle = [[CTBundleCache sharedInstance].cache objectForKey:bundleName];
    if ([bundle isKindOfClass:[NSNumber class]]) {
        // NSNotFound
        return nil;
    }
    if (bundle != nil && [bundle isKindOfClass:[NSBundle class]]) {
        return bundle;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    if (!bundlePath) {
        bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle" inDirectory:@"Frameworks"];
    }
    if (!bundlePath) {
        bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle" inDirectory:[NSString stringWithFormat:@"Frameworks/%@.framework", bundleName]];
    }
    
    bundle = [NSBundle bundleWithPath:bundlePath];
    
    if (shouldReturnMainBundleIfBundleNotFound == YES && bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    
    if (bundle != nil) {
        [[CTBundleCache sharedInstance].cache setObject:bundle forKey:bundleName];
    } else {
        [[CTBundleCache sharedInstance].cache setObject:@(NSNotFound) forKey:bundleName];
    }

    return bundle;
}

@end


