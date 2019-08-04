//
//  NSObject+CTNavigation.h
//  CTHandyCategories
//
//  Created by casa on 2018/3/1.
//  Copyright © 2018年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (CTNavigation)

- (UIViewController * _Nullable)ct_topmostViewController;
- (void)ct_pushViewController:(UIViewController * _Nonnull)viewController animated:(BOOL)animated;
- (void)ct_presentViewController:(UIViewController * _Nonnull)viewControllerToPresent animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

@end
