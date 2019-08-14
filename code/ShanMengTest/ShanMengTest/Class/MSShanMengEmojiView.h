//
//  MSShanMengEmojiView.h
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSShanMengModel;

typedef void (^CMObjectResultBlock)(id object);
static NSUInteger const kEmojiPage = 20;

@protocol MSShanMengEmojiViewDelegate <NSObject>


/**
 选中的gif表情

 @param model gif的model
 */
- (void)msShanMengEmojiViewSelectModel:(MSShanMengModel *)model;


/**
 滚动到最末端时回调

 @param pageIndex 下一页的页数
 */
- (void)msShanMengEmojiViewPageIndex:(NSUInteger)pageIndex;

@end


@interface MSShanMengEmojiView : UIView

- (void)refreshUIWithGifArray:(NSArray<MSShanMengModel *> *)array;
@property (nonatomic, copy) CMObjectResultBlock emojiTapBlock;
@property (nonatomic, weak) id<MSShanMengEmojiViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
