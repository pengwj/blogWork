//
//  MSShanMengCollectionCell.h
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSShanMengModel;

NS_ASSUME_NONNULL_BEGIN

@interface MSShanMengCollectionCell : UICollectionViewCell

- (void)refreshCellWithModel:(MSShanMengModel *)model size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
