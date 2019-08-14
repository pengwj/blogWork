//
//  MSShanMengCollectionCell.m
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "MSShanMengCollectionCell.h"
#import "MSShanMengModel.h"
//#import <YYImage/YYImage.h>

#import <SDWebImage/SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>

@interface MSShanMengCollectionCell ()

@property (nonatomic, strong) UIImageView *gifImageView;

@end

@implementation MSShanMengCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeUI];
    }
    return self;
}

- (void)makeUI
{
    
    self.backgroundColor = [UIColor clearColor];

    self.gifImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.gifImageView.backgroundColor = [UIColor whiteColor];
    self.gifImageView.layer.masksToBounds = YES;
    self.gifImageView.layer.cornerRadius = 6.0f;
    self.gifImageView.contentMode =  UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.gifImageView];
}

- (void)refreshCellWithModel:(MSShanMengModel *)model size:(CGSize)size
{
    // Add coder
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    
    [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:model.thumb.webp] placeholderImage:nil];
    self.gifImageView.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
