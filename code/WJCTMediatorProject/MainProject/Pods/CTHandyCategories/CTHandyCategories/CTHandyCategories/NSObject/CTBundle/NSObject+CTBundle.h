//
//  NSObject+CTBundle.h
//  CTHandyCategories
//
//  Created by casa on 2018/3/7.
//  Copyright © 2018年 casa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CTBundle)

- (NSBundle *)ct_bundleWithName:(NSString *)bundleName shouldReturnMainBundleIfBundleNotFound:(BOOL)shouldReturnMainBundleIfBundleNotFound;

@end
