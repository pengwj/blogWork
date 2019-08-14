//
//  MSShanMengViewModel.h
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CMArrayResultBlock)(NSArray *objects, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface MSShanMengViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataArray;

- (void)getShanMengEmojiWithKeyword:(NSString *)keyword offset:(NSUInteger)offset limit:(NSUInteger)limit block:(CMArrayResultBlock)block;
- (void)removeEmojiKeyWord;

@end

NS_ASSUME_NONNULL_END
