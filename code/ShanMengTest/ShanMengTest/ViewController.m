//
//  ViewController.m
//  ShanMengTest
//
//  Created by Admin on 2019/8/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ViewController.h"
#import "MSShanMengViewModel.h"
#import "MSShanMengEmojiView.h"
#import "MSShanMengModel.h"

#import "MSShanMengLargeEmojiViewController.h"

#import <SDWebImage/SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <SDWebImageWebPCoder/SDImageWebPCoder.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_RATE   ([UIScreen mainScreen].bounds.size.width/375.0)

@interface ViewController ()<UITextFieldDelegate,MSShanMengEmojiViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *shanmengTextField;
@property (strong, nonatomic) MSShanMengViewModel *viewModel;
@property (strong, nonatomic) MSShanMengEmojiView *emojiView;
@property (strong, nonatomic) IBOutlet UIImageView *emojiImageView;
@property (strong, nonatomic) NSString *gifUrl;
@property (nonatomic, assign) NSUInteger pageIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self makeEmojiUI];
    [self makeOtherUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.viewModel removeEmojiKeyWord];
}

- (void)makeOtherUI
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmojiView:)];
    [self.emojiImageView addGestureRecognizer:tap];
    self.emojiImageView.userInteractionEnabled = YES;
}

- (void)makeEmojiUI
{
    [self.shanmengTextField addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    
    self.pageIndex = 0;
    self.emojiView = [[MSShanMengEmojiView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 82)];
    self.emojiView.delegate = self;
    [self.view addSubview:self.emojiView];
}


- (void)refreshEmojiViewWithArray:(NSArray *)array
{
    [self.emojiView refreshUIWithGifArray:array];
}

- (void)tapEmojiView:(UITapGestureRecognizer *)tap
{
    MSShanMengLargeEmojiViewController *vc = [[MSShanMengLargeEmojiViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        [vc refreshLargeGitWithUrl:self.gifUrl];
    }];
}

- ( void )textFieldDidBeginEditing:( UITextField*)textField
{
    
}

- ( void )textFieldDidEndEditing:( UITextField *)textField
{
    
}

-(void)changedTextField:(UITextField *)textField
{
    __weak __typeof(self)weakSelf = self;
    [self.viewModel getShanMengEmojiWithKeyword:textField.text offset:0 limit:kEmojiPage block:^(NSArray *objects, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf refreshEmojiViewWithArray:objects];
        
    }];
}

#pragma mark -- MSShanMengEmojiViewDelegate
- (void)msShanMengEmojiViewPageIndex:(NSUInteger)pageIndex
{
    if (pageIndex>self.pageIndex) {
        // 分页的预言，没验证测试
    }
}

- (void)msShanMengEmojiViewSelectModel:(MSShanMengModel *)model
{
    self.gifUrl = model.thumb.gif;
    [self.emojiImageView sd_setImageWithURL:[NSURL URLWithString:model.thumb.webp] placeholderImage:nil];
}

- (MSShanMengViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[MSShanMengViewModel alloc] init];
    }
    return _viewModel;
}


@end
